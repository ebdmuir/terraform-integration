data "template_file" "plan_spec" {
  template = var.vis_enabled ? file("${path.module}/files/buildspec.plan.yaml.tpl") : file("${path.module}/files/buildspec.plan-vis.yaml.tpl")
  vars = {
    id = "${var.system_id}_repository",
    bucket = var.vis_enabled ? var.vis_bucket : ""
  }
}

resource "local_file" "plan_spec" {
  content = data.template_file.plan_spec.rendered
  filename = "buildspec.plan.yaml"
}

data "template_file" "apply_spec" {
  template = file("${path.module}/files/buildspec.apply.yaml.tpl")
  vars = {
    secgroup = var.security_group
  }
}

resource "local_file" "apply_spec" {
  content = data.template_file.apply_spec.rendered
  filename = "buildspec.apply.yaml"
}

resource "aws_codebuild_project" "plan" {
  name = "${var.system_id}_plan"
  description = var.build_description

  build_timeout = "5"
  service_role  = aws_iam_role.build.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.plan.yaml"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "franscape-instance"
      stream_name = "${var.system_id}_plan"
    }
  }

  tags = {
    Name     = var.build_description
    Project  = "franscape"
  }
}

resource "aws_codebuild_project" "apply" {
  name = "${var.system_id}_apply"
  description = var.build_description

  build_timeout = "25"
  service_role  = aws_iam_role.build.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.apply.yaml"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "REPO"
      value = aws_codecommit_repository.repository.clone_url_http
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "franscape-instance"
      stream_name = "${var.system_id}_apply"
    }
  }

  tags = {
    Name     = var.build_description
    Project  = "franscape"
  }
}