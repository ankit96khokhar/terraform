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
    image: terraform-python-venv:local
    imagePullPolicy: IfNotPresent
    command: ["cat"]
    tty: true
"""
    }
  }

  parameters {
    string(
      name: 'TENANT',
      description: 'Tenant / Business Unit name (example: tenant-a)'
    )

    choice(
      name: 'ENV',
      choices: ['dev', 'staging', 'prod'],
      description: 'Terraform environment'
    )

    choice(
      name: 'REGION',
      choices: ['ap-south-1', 'us-east-1', 'eu-west-1'],
      description: 'AWS region'
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
    BLUEPRINT_REPO = 'git@github.com:ankit96khokhar/blueprint-config.git'
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Checkout Blueprint Config Repo') {
      steps {
        dir('blueprints'){
          git(
            url: env.BLUEPRINT_REPO
            branch: 'main',
            credentialsId: 'github-ssh'            
          )
        }
      }
    }

//     stage('Discover & Select Modules') {
//       steps {
//         script {
//           def modules = sh(
//             script: "ls -d modules/*/ | cut -d'/' -f2",
//             returnStdout: true
//           ).trim().split("\n")

//           echo "Discovered modules: ${modules}"

//           def selection = input(
//             message: """Available modules:
// ${modules.join(', ')}

// Enter:
// - ALL
// - OR comma-separated list (example: eks,vpc)
// """,
//             parameters: [
//               string(
//                 name: 'SELECTED_MODULES',
//                 defaultValue: 'ALL',
//                 description: 'Modules to apply'
//               )
//             ]
//           )

//           env.SELECTED_MODULES = selection.trim()
//         }
//       }
//     }


    stage('Check Tenant Blueprint Exists') {
      steps {
        sh """
          test -f blueprints/tenants/${params.TENANT}/${params.ENV}/${params.REGION}.yaml \
          || (echo "❌ Tenant blueprint not found" && exit 1)
        """
      }
    }

    stage('Validate Blueprint and Generate tf vars') {
      steps {
        sh """
          set -e
          python3 scripts/yamls_to_tfvars_json.py \
          blueprints/schema/tenant-schema.yaml \
          blueprints/tenants/${params.TENANT}/${params.ENV}/${params.REGION}.yaml \
          tfvars.json
        """
      }
    }

    stage('Show Generated tfvars') {
      steps {
        sh "cat tfvars.json"
      }
    }

    stage('Terraform Init & Plan') {
      when {
        expression { params.ACTION != 'destroy' }
      }
      steps {
        withAWS(
          credentials: 'aws-bootstrap',
          role: 'arn:aws:iam::907793002691:role/terraform-ci-role',
          roleSessionName: 'jenkins-terraform'
        ) {
          sh """
            terraform init -reconfigure \
              -backend-config="backend/backend_${params.ENV}.hcl" \
              -backend-config="key=${params.TENANT}/${params.ENV}/${params.REGION}/terraform.tfstate" \
              -backend-config="region=${params.REGION}"
          """

          sh "terraform plan -var-file=tfvars.json -out=tfplan"
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
        expression { params.ACTION == 'destroy' }
      }
      steps {
        withAWS(
          credentials: 'aws-bootstrap',
          role: 'arn:aws:iam::907793002691:role/terraform-ci-role',
          roleSessionName: 'jenkins-terraform'
        ) {
          sh """
            terraform init -reconfigure \
              -backend-config="backend/backend_${params.ENV}.hcl" \
              -backend-config="key=${params.TENANT}/${params.ENV}/${params.REGION}/terraform.tfstate" \
              -backend-config="region=${params.REGION}"
          """

          sh "terraform plan -destroy -var-file=tfvars.json -out=tfplan-destroy"
        }
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
