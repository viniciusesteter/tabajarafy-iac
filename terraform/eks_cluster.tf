resource "aws_eks_cluster" "main" {
	name     = var.cluster_name
	role_arn = aws_iam_role.eks_cluster_role.arn

	vpc_config {
		subnet_ids              = [for s in aws_subnet.private : s.id]
		endpoint_public_access  = true
	}

	tags = var.tags_eks_cluster

	   depends_on = [
		   aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
		   aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
		   aws_iam_role_policy_attachment.eks_passrole_attach,
		   aws_iam_group_policy_attachment.user_eks_passrole,
		   aws_subnet.private
	   ]
}