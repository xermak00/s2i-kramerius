FROM openshift/base-centos7

MAINTAINER Martin Rumanek <martin@rumanek.cz>
ENV GRADLE_VERSION=2.12
ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.5.5
ENV CATALINA_HOME /usr/local/tomcat
ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
ENV JDBC_DRIVER_DOWNLOAD_URL https://jdbc.postgresql.org/download/postgresql-9.4.1208.jar

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

WORKDIR $CATALINA_HOME

RUN set -ex \
	&& for key in \
		05AB33110949707C93A279E3D3EFE6B686867BA6 \
		07E48665A34DCAFAE522E5E6266191C37C037D42 \
		47309207D818FFD8DCD3F83F1931D684307A10A5 \
		541FBE7D8F78B25E055DDEE13C370389288584E7 \
		61B832AC2F1C5A90F0F9B00A1C506407564C17A3 \
		79F7026C690BAA50B92CD8B66A3AD3F4F22C4FED \
		9BA44C2621385CB966EBA586F72C284D731FABEE \
		A27677289986DB50844682F8ACB77FC2E86E29AC \
		A9C5DF4D22E99998D9875A5110C01C5A2F6059E7 \
		DCFD35E0BF8CA7344752DE8B6FB21E8933C60243 \
		F3A04C595DB5B6A5F1ECA43E3B7BBB100D811BBE \
		F7DA48BB64BCB84ECBA7EE6935CD23C10D498E23 \
	; do \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done

RUN set -x \
	&& curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
	&& curl -fSL "$TOMCAT_TGZ_URL.asc" -o tomcat.tar.gz.asc \
	&& gpg --batch --verify tomcat.tar.gz.asc tomcat.tar.gz \
	&& tar -xvf tomcat.tar.gz --strip-components=1 \
	&& rm bin/*.bat \
	&& rm tomcat.tar.gz*

RUN curl -sL "$JDBC_DRIVER_DOWNLOAD_URL" -o $CATALINA_HOME/lib/postgresql-9.4.1208.jar
RUN curl -sL http://ftp-devel.mzk.cz/kramerius/master/kramerius/rightseditor.war -o $CATALINA_HOME/webapps/rightseditor.war
ADD context.xml $CATALINA_HOME/conf/context.xml
ADD search.xml $CATALINA_HOME/conf/Catalina/localhost/search.xml
ADD web.xml $CATALINA_HOME/conf/web.xml

# Kramerius auth
ENV JAAS_CONFIG=$CATALINA_HOME/conf/jaas.config
ADD jaas.conf $CATALINA_HOME/conf/jaas.config
ENV JAVA_OPTS -Djava.awt.headless=true -Dfile.encoding=UTF8  -Djava.security.auth.login.config=$JAAS_CONFIG -Duser.home=$HOME

ADD rewrite.config $CATALINA_HOME/conf/Catalina/localhost/
ADD server.xml $CATALINA_HOME/conf/

COPY  ["run", "assemble", "save-artifacts", "usage", "/usr/libexec/s2i/"]

RUN wget --no-verbose https://github.com/ceskaexpedice/kramerius/releases/download/v5.1.0/Installation-5.1.zip && \
    unzip -j Installation-5.1.zip Installation-5.1/fedora/* -d /tmp/fedora

ENV TOMCAT_USER tomcat
ENV TOMCAT_UID 8983
RUN groupadd -r $TOMCAT_USER && \
    useradd -r -u $TOMCAT_UID -g $TOMCAT_USER $TOMCAT_USER -d $HOME

RUN mkdir -p $HOME/.kramerius4/lp/
RUN chown -R $TOMCAT_USER:$TOMCAT_USER $HOME $CATALINA_HOME

RUN chmod -R ugo+rwx $HOME $CATALINA_HOME

USER 8983
EXPOSE 8080

CMD ["/usr/libexec/s2i/usage"]
