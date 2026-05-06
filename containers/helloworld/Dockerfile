FROM alpine:3.19

# bash is needed by Nextflow's process wrappers ("/bin/bash: no such file"
# when run via singularity exec).
RUN apk add --no-cache bash

COPY hello.sh /usr/local/bin/hello
RUN chmod +x /usr/local/bin/hello

ENTRYPOINT ["/usr/local/bin/hello"]
