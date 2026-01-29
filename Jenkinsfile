pipeline {
  agent {
    kubernetes {
      defaultContainer 'terraform'
      idleMinutes 1
      yaml """
apiVersion: v1
kind: Pod
spec:
  terminationGracePeriodSeconds: 30
  containers:
  - name: terraform
    image: hashicorp/terraform:1.6.6
    command: ["cat"]
    tty: true
    imagePullPolicy: IfNotPresent
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
        sh """
          terraform init \
            -backend-config="key=eks/${ENV}/terraform.tfstate"
        """
      }
    }

    stage('Terraform Plan') {
      steps {
        sh """
          terraform plan \
            -var-file=env/${ENV}.tfvars \
            -out=tfplan
        """
      }
    }
  }
}
