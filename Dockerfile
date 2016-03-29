# nginx-centos7
# Here you can use whatever image base is relevant for your application.
FROM openshift/base-centos7

# Here you can specify the maintainer for the image that you're building
MAINTAINER Martin Rumanek <martin@rumanek.cz>
ENV GRADLE_VERSION=2.9

# Set the labels that are used for Openshift to describe the builder image.
LABEL io.k8s.description="Kramerius" \
    io.k8s.display-name="Kramerius" \
    io.openshift.expose-services="8080:http" \
    io.openshift.tags="builder,kramerius" \
    io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"

RUN INSTALL_PKGS="tar java-1.8.0-openjdk java-1.8.0-openjdk-devel" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    wget -nv  https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip -O gradle.zip && \
    unzip -qq gradle.zip -d /usr/local && \
    rm gradle.zip

RUN  ln -sf /usr/local/gradle-$GRADLE_VERSION/bin/gradle /usr/local/bin/gradle

ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8

COPY  ["run", "assemble", "save-artifacts", "usage", "/usr/libexec/s2i/"]

RUN chown -R 1001:0 $HOME

USER 1001

CMD ["/usr/libexec/s2i/usage"]
