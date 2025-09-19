# Role for EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
	name               = var.eks_cluster_role_name
	assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
	tags = var.tags_eks_iam
}

data "aws_iam_policy_document" "eks_assume_role" {
	statement {
		actions = ["sts:AssumeRole"]
		principals {
			type        = "Service"
			identifiers = ["eks.amazonaws.com"]
		}
	}
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
	role       = aws_iam_role.eks_cluster_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
	role       = aws_iam_role.eks_cluster_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_policy" "eks_passrole" {
	name        = var.eks_cluster_pass_role
	description = "Allow EKS to pass the cluster role"
	policy = jsonencode({
		Version = "2012-10-17"
		Statement = [
			{
				Effect = "Allow"
				Action = "iam:PassRole"
				Resource = aws_iam_role.eks_cluster_role.arn
			}
		]
	})
	tags = var.tags_eks_iam
}

resource "aws_iam_role_policy_attachment" "eks_passrole_attach" {
	role       = aws_iam_role.eks_cluster_role.name
	policy_arn = aws_iam_policy.eks_passrole.arn
}

# Role for worker nodes
resource "aws_iam_role" "eks_node_role" {
	name               = var.eks_node_role_name
	assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
	tags = var.tags_nodes_iam
}

data "aws_iam_policy_document" "node_assume_role" {
	statement {
		actions = ["sts:AssumeRole"]
		principals {
			type        = "Service"
			identifiers = ["ec2.amazonaws.com"]
		}
	}
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
	role       = aws_iam_role.eks_node_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
	role       = aws_iam_role.eks_node_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
	role       = aws_iam_role.eks_node_role.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_policy" "node_passrole" {
	name        = var.eks_node_pass_role
	description = "Allow EKS to pass the node group role"
	policy = jsonencode({
		Version = "2012-10-17"
		Statement = [
			{
				Effect = "Allow"
				Action = [
					"iam:PassRole", 
				]
				Resource = aws_iam_role.eks_node_role.arn
			}
		]
	})
}

resource "aws_iam_role_policy_attachment" "node_passrole_attach" {
	role       = aws_iam_role.eks_node_role.name
	policy_arn = aws_iam_policy.node_passrole.arn
}

## Attach policies to group
resource "aws_iam_group_policy_attachment" "user_eks_passrole" {
  policy_arn = aws_iam_policy.eks_passrole.arn
  group      = var.iam_group_name
}

resource "aws_iam_group_policy_attachment" "user_node_passrole" {
  policy_arn = aws_iam_policy.node_passrole.arn
  group      = var.iam_group_name
}