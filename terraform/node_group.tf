resource "aws_eks_node_group" "node_group" {
	cluster_name    = aws_eks_cluster.main.name
	node_group_name = "${var.node_group_name}-spot"
	node_role_arn   = aws_iam_role.eks_node_role.arn
	subnet_ids      = [for s in aws_subnet.private : s.id]
	tags = var.tags_ng
	scaling_config {
		desired_size = var.desired_size
		max_size     = var.max_size
		min_size     = var.min_size
	}
	instance_types = [var.node_instance_type]
	capacity_type  = "SPOT"
	node_repair_config {
		enabled = true
	}
	   depends_on = [
		   aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
		   aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
		   aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
		   aws_iam_role_policy_attachment.node_passrole_attach,
		   aws_iam_group_policy_attachment.user_node_passrole,
		   aws_eks_cluster.main,
		   aws_subnet.private
	   ]
}