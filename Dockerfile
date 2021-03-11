FROM jenkins/jenkins:lts@sha256:3647dc7dcf43faf20a612465dc1aed6bf510893ff9724df4050604af80123b85

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

ADD plugins-with-dependencies.txt /usr/share/jenkins/ref/plugins-with-dependencies.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins-with-dependencies.txt --latest false --verbose

# Create three folders:
# /var/jenkins_home/mounts/init.groovy.d - which should contain groovy init scripts (this is particuarly used to create the SeedJob)
# /var/jenkins_home/mounts/job-dsl - which should contain Job DSL scripts that will create the pipeline jobs
#RUN mkdir -p /var/jenkins_home/mounts \
#    && mkdir /var/jenkins_home/mounts/config \
#    && mkdir /var/jenkins_home/mounts/init.groovy.d \
#    && mkdir /var/jenkins_home/mounts/job-dsl \
#    && rmdir /usr/share/jenkins/ref/init.groovy.d \
#    && mkdir -p /usr/share/jenkins/ref/jobs/SeedJob \
#    && ln -s /var/jenkins_home/mounts/config /var/jenkins_home/config \
#    && ln -s /var/jenkins_home/mounts/init.groovy.d /usr/share/jenkins/ref/init.groovy.d \
#    && ln -s /var/jenkins_home/mounts/job-dsl /usr/share/jenkins/ref/jobs/SeedJob/workspace
