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

    choice(
      name: 'ACTION',
      choices: ['plan', 'apply', 'destroy'],
      description: 'Terraform action to perform'
    )

    choice(
      name: 'CONFIRM_DESTROY',
      choices: ['NO', 'YES'],
      description: 'Required for DESTROY'
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

    stage('Discover & Select Modules') {
      steps {
        script {
          def modules = sh(
            script: "ls -d modules/*/ | cut -d'/' -f2",
            returnStdout: true
          ).trim().split("\n")

          echo "Discovered modules: ${modules}"

          def selection = input(
            message: """Available modules:
${modules.join(', ')}

Enter:
- ALL
- OR comma-separated list (example: eks,vpc)
""",
            parameters: [
              string(
                name: 'SELECTED_MODULES',
                defaultValue: 'ALL',
                description: 'Modules to apply'
              )
            ]
          )

          env.SELECTED_MODULES = selection.trim()
        }
      }
    }

    stage('Terraform Init & Plan') {
      steps {
        withAWS(
          credentials: 'aws-bootstrap',
          role: 'arn:aws:iam::907793002691:role/terraform-ci-role',
          roleSessionName: 'jenkins-terraform'
        ) {
          script {

            sh """
              terraform init \
                -backend-config="bucket=ankit-eks-tf-state-12345" \
                -backend-config="key=eks/${params.ENV}/terraform.tfstate" \
                -backend-config="region=ap-south-1" \
                -backend-config="dynamodb_table=terraform-locks" \
                -backend-config="encrypt=true"
            """

            if (env.SELECTED_MODULES == 'ALL') {
              sh "terraform plan -var-file=env/${params.ENV}.tfvars -out=tfplan"
            } else {
              def targets = env.SELECTED_MODULES
                .split(',')
                .collect { "-target=module.${it.trim()}" }
                .join(' ')

              sh """
                terraform plan \
                  -var-file=env/${params.ENV}.tfvars \
                  ${targets} \
                  -out=tfplan
              """
            }
          }
        }
      }
    }

    stage('Terraform Apply') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        withAWS(
          credentials: 'aws-bootstrap',
          role: 'arn:aws:iam::907793002691:role/terraform-ci-role',
          roleSessionName: 'jenkins-terraform'
        ) {
          sh "terraform apply -auto-approve tfplan"
        }
      }
    }

    stage('Terraform Destroy Plan') {
      when {
        allOf {
          expression { params.ACTION == 'destroy' }
          expression { params.CONFIRM_DESTROY == 'YES' }
          expression { params.ENV != 'prod' }
        }
      }
      steps {
        withAWS(
          credentials: 'aws-bootstrap',
          role: 'arn:aws:iam::907793002691:role/terraform-ci-role',
          roleSessionName: 'jenkins-terraform'
        ) {
          script {

            if (env.SELECTED_MODULES == 'ALL') {
              sh "terraform plan -destroy -var-file=env/${params.ENV}.tfvars -out=tfplan-destroy"
            } else {
              def targets = env.SELECTED_MODULES
                .split(',')
                .collect { "-target=module.${it.trim()}" }
                .join(' ')

              sh """
                terraform plan -destroy \
                  -var-file=env/${params.ENV}.tfvars \
                  ${targets} \
                  -out=tfplan-destroy
              """
            }
          }
        }
        )
      }
    }

    stage ('Terraform Destroy Apply') {
      when {
        allOf {
          expression { params.ACTION == 'destroy' }
          expression { params.CONFIRM_DESTROY == 'YES' }
          expression { params.ENV != 'prod' }
        }
      }
      steps {
        withAWS(
          credentials: 'aws-bootstrap',
          role: 'arn:aws:iam::907793002691:role/terraform-ci-role',
          roleSessionName: 'jenkins-terraform'
        ) {
          sh "terraform apply -auto-approve tfplan-destroy"
        }
      }
    }
  }
}
