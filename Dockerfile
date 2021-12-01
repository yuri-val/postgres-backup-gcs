FROM postgres
RUN apt-get update && apt-get install -y curl python3
# Install google cloud sdk (gcloud and gsutil used in backup.sh)
RUN curl -sSL https://sdk.cloud.google.com | bash
ENV PATH $PATH:/root/google-cloud-sdk/bin

RUN mkdir /data
ADD backup.sh /scripts/backup.sh
RUN chmod +x /scripts/backup.sh

CMD ["/scripts/backup.sh"]
