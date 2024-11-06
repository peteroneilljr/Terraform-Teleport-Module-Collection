// Policy to permit cluster to access DynamoDB tables (Cluster state, events, and SSL)
data "aws_eks_node_groups" "this" {
  cluster_name = var.eks_cluster_name
}

data "aws_eks_node_group" "this" {
  for_each = data.aws_eks_node_groups.this.names

  cluster_name = var.eks_cluster_name
  node_group_name = each.value
}

resource "aws_iam_role_policy_attachment" "teleport_cluster_dynamodb" {
  for_each   = data.aws_eks_node_group.this
  role       = split("/", data.aws_eks_node_group.this[count.index].node_role_arn)[1]
  policy_arn = aws_iam_policy.teleport_cluster_dynamodb.arn
}
resource "aws_iam_policy" "teleport_cluster_dynamodb" {
  name = "${var.eks_cluster_name}-cluster-dynamodb"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllActionsOnTeleportDB",
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": "${aws_dynamodb_table.teleport_backend.arn}"
        },
        {
            "Sid": "AllActionsOnTeleportStreamsDB",
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": "${aws_dynamodb_table.teleport_backend.arn}/stream/*"
        },
        {
            "Sid": "AllActionsOnTeleportEventsDB",
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": "${aws_dynamodb_table.teleport_events.arn}"
        },
        {
            "Sid": "AllActionsOnTeleportEventsIndexDB",
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": "${aws_dynamodb_table.teleport_events.arn}/index/*"
        }
    ]
}
EOF
}

// Policy to permit cluster to talk to S3 (Session recordings)
resource "aws_iam_role_policy_attachment" "teleport_cluster_s3" {
  for_each   = data.aws_eks_node_group.this
  role       = split("/", data.aws_eks_node_group.this[count.index].node_role_arn)[1]
  policy_arn = aws_iam_policy.teleport_cluster_s3.arn
}
resource "aws_iam_policy" "teleport_cluster_s3" {
  name = "${var.eks_cluster_name}-cluster-s3"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
     {
       "Effect": "Allow",
       "Action": [
          "s3:ListBucketVersions",
          "s3:ListBucketMultipartUploads",
          "s3:ListBucket",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketVersioning"
      ],
       "Resource": ["${aws_s3_bucket.teleport_sessions.arn}"]
     },
     {
       "Effect": "Allow",
       "Action": [
          "s3:GetObjectVersion",
          "s3:GetObjectRetention",
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
       ],
       "Resource": ["${aws_s3_bucket.teleport_sessions.arn}/*"]
     }
   ]
 }

EOF

}


# ---------------------------------------------------------------------------- #
# route53
# ---------------------------------------------------------------------------- #
// Auth server uses route53 to get certs for domain, this allows
// read/write operations from the zone.
resource "aws_iam_role_policy_attachment" "teleport_auth_route53" {
  for_each   = data.aws_eks_node_group.this
  role       = split("/", data.aws_eks_node_group.this[count.index].node_role_arn)[1]
  policy_arn = aws_iam_policy.teleport_auth_route53.arn
}
resource "aws_iam_policy" "teleport_auth_route53" {
  name = "${var.eks_cluster_name}-auth-route53"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "certbot-dns-route53 policy",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:GetChange"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect" : "Allow",
            "Action" : [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource" : [
                "arn:aws:route53:::hostedzone/${var.aws_route53_zone_id}"
            ]
        }
    ]
}
EOF

}
