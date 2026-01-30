pipeline {
  agent {
    kubernetes {
      defaultContainer 'terraform'
      idleMinutes 1
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: terraform
    image: hashicorp/terraform:1.6.6
    command: ["cat"]
    tty: true
"""
    }
  }

  parameters {
    choice(
      name: 'ENV',
      choices: ['dev', 'staging', 'prod'],
      description: 'Terraform environment'
    )
  }

  environment {
    TF_IN_AUTOMATION = "true"
    TF_INPUT = "false"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        withAWS(
          credentials: 'aws-bootstrap',
          role: 'arn:aws:iam::907793002691:role/terraform-ci-role',
          roleSessionName: 'jenkins-terraform'
        ) {
          sh """
            terraform init \
              -backend-config="bucket=ankit-eks-tf-state-12345" \
              -backend-config="key=eks/${params.ENV}/terraform.tfstate" \
              -backend-config="region=ap-south-1" \
              -backend-config="dynamodb_table=terraform-locks" \
              -backend-config="encrypt=true"

            terraform plan \
              -var-file=env/${params.ENV}.tfvars \
              -out=tfplan              
          """
        }
      }
    }

  }
}
