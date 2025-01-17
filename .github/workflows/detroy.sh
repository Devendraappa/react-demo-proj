name: Destroy Terraform Workflow 
on:
  push:
    branches:
      - main


permissions:
  contents: read
  id-token: write

jobs:
  terraform:
    name: Terraform Destroy Workflow
    runs-on: ubuntu-latest

    steps:
      # Step 1: Checkout code
      - name: Checkout code
        uses: actions/checkout@v3

      # Step 2: Setup Terraform
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.6

      # Step 3: Configure AWS Credentials
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/${{ secrets.ROLE_NAME }}
          aws-region: ${{ secrets.AWS_REGION }}
          role-session-name: TerraformDestroySession

      # Step 4: Terraform Init (INFO logging)
      - name: Terraform Init
        env:
          FAILURE_FLAG: false
          TF_LOG: INFO  # Set Terraform logging to INFO for general info messages
        run: |
          terraform init || echo "FAILURE_FLAG=true" >> $GITHUB_ENV

      # Step 5: Terraform Destroy (TRACE logging)
      - name: Terraform Destroy
        env:
          TF_LOG: TRACE  # Set Terraform logging to TRACE for detailed logs
          TF_LOG_PATH: terraform_destroy.log
          FAILURE_FLAG: false
        run: |
          terraform destroy -auto-approve || echo "FAILURE_FLAG=true" >> $GITHUB_ENV

      # Step 6: Ensure Logs Directory Exists (DEBUG logging)
      - name: Ensure Logs Directory Exists
        env:
          TF_LOG: DEBUG  # Set Terraform logging to DEBUG for detailed process steps
        run: mkdir -p $GITHUB_WORKSPACE/destroylogs

      # Step 7: Copy Terraform Destroy Logs to Logs Directory (WARN logging)
      - name: Copy Terraform Destroy Logs to Logs Directory
        env:
          TF_LOG: WARN  # Set Terraform logging to WARN to capture potential issues
        run: |
          if [ -f terraform_destroy.log ]; then
            cp terraform_destroy.log $GITHUB_WORKSPACE/destroylogs/
          fi

      # Step 8: Print Logs on Failure (ERROR logging)
      - name: Print Logs on Failure
        if: ${{ env.FAILURE_FLAG == 'true' }}
        env:
          TF_LOG: ERROR  # Set Terraform logging to ERROR to capture critical failure messages
        run: |
          echo "Terraform Destroy failed. Logs are as follows:"
          cat $GITHUB_WORKSPACE/logs/terraform_destroy.log || true

      # Step 9: Upload Terraform Destroy Logs as Artifacts
      - name: Upload Terraform Destroy Logs as Artifacts
        if: always()  # This will always run
        uses: actions/upload-artifact@v3
        with:
          name: terraform-destroy-logs
          path: destroylogs/

      # Step 12: Upload Logs to S3 (Both Success and Failure)
      - name: Upload Logs to S3
        if: always()  # Ensure this runs even if the workflow fails
        run: |
          aws s3 cp $GITHUB_WORKSPACE/destroylogs/ s3://${{ secrets.S3_BUCKET_NAME }}/destroylogs/ --recursive

      # Step 10: Fail Workflow if Terraform Destroy Fails
      - name: Fail Workflow if Terraform Destroy Fails
        if: ${{ env.FAILURE_FLAG == 'true' }}
        run: |
          echo "Terraform Destroy failed. Marking workflow as failed."
          exit 1

      # Step 11: Send SNS Notification (Success or Failure)
      - name: Send SNS Notification
        if: always()  # Ensure this runs even if the workflow fails or succeeds
        run: |
          # Check the FAILURE_FLAG to determine whether the workflow failed
          if [[ "${{ env.FAILURE_FLAG }}" == "true" ]]; then
            SUBJECT="Terraform Destroy Workflow Status - failure"
            BODY="The Terraform destroy workflow has failed. Please check the logs for details."
          else
            SUBJECT="Terraform Destroy Workflow Status - success"
            BODY="The Terraform destroy workflow has completed successfully. Please check the logs for details."
          fi

          # Publish the SNS message with the status
          aws sns publish \
            --topic-arn arn:aws:sns:${{ secrets.AWS_REGION }}:${{ secrets.AWS_ACCOUNT_ID }}:${{ secrets.SNS_TOPIC_NAME }} \
            --message "$BODY" \
            --subject "$SUBJECT"
        env:
          AWS_REGION: ${{ secrets.AWS_REGION }}
