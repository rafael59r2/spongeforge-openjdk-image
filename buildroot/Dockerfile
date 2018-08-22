FROM openjdk:8-jre-alpine
LABEL Name=spongeforge Version=0.0.1 Author=RR59
RUN apk add -U \
          openssl \
          imagemagick \
          lsof \
          su-exec \
          bash \
          curl iputils wget \
          git \
          jq \
          mysql-client \
          tmux && \
          rm -rf /var/cache/apk/*

ENV	SPONGEFORGE_USR="spongeforge"
ENV	SPONGEFORGE_HOME="/opt/${SPONGEFORGE_USR}"
ENV	SPONGEFORGE_WORKDIR="${SPONGEFORGE_HOME}/workdir" \
	SPONGEFORGE_TMUX_SNAME="MCConsole"

# SECURITY: to avoid undiscovered vulnerabilities in java, SPONGEFORGE or any mods/plugins,
# we run server as unprivileged user
RUN	mkdir -p "${SPONGEFORGE_HOME}" \
&&	addgroup -S ${SPONGEFORGE_USR} \
&&	adduser -S -s /bin/sh -h "${SPONGEFORGE_HOME}" -g ${SPONGEFORGE_USR} -G ${SPONGEFORGE_USR} ${SPONGEFORGE_USR}

# Script that implements properly startup and shutdown routines
ADD	entrypoint.sh /usr/local/bin/entrypoint
RUN	chmod +x /usr/local/bin/entrypoint

# Version setup
ENV	MINECRAFT_VER="1.12.2" \
	FORGE_VER="14.23.4.2705" \
    SPONGE_VER="2705-7.1.0-BETA-3169"

# Shortcuts and stuff, usually not for change (part 2)
ENV FORGE_INST_JAR="/tmp/Forge-installer.jar" \
    FORGE_SERVER_JAR="Forge-server.jar" \
    SPONGE_JAR="spongemod.jar"

ENV FORGE_JAR_LINK="http://files.minecraftforge.net/maven/net/minecraftforge/forge/${MINECRAFT_VER}-${FORGE_VER}/forge-1.12.2-${FORGE_VER}-installer.jar" \
    SPONGE_JAR_LINK="https://repo.spongepowered.org/maven/org/spongepowered/spongeforge/${MINECRAFT_VER}-${SPONGE_VER}/spongeforge-${MINECRAFT_VER}-${SPONGE_VER}.jar"

WORKDIR	"${SPONGEFORGE_HOME}"

RUN wget -O ${FORGE_INST_JAR} ${FORGE_JAR_LINK} \
&&  wget -O ${SPONGE_JAR} ${SPONGE_JAR_LINK} \
&&  java -jar ${FORGE_INST_JAR} --installServer \
&& mv *forge* ${FORGE_SERVER_JAR} \
&& rm -f ${FORGE_INST_JAR} \
&& chown -R root.root "${SPONGEFORGE_HOME}" \
&& find "${SPONGEFORGE_HOME}" -type d -exec chmod 755 "{}"  \; \
&& find "${SPONGEFORGE_HOME}" -type f -exec chmod 644 "{}"  \; \
&& chmod 4777 /sbin/su-exec


# Preparing workplace
RUN mkdir -p "${SPONGEFORGE_WORKDIR}" \
&& echo "eula=true" > "${SPONGEFORGE_WORKDIR}/eula.txt" \
&& mkdir -p "${SPONGEFORGE_WORKDIR}/mods" \
&& mv ${SPONGE_JAR} "${SPONGEFORGE_WORKDIR}/mods" \
&& chown -R ${SPONGEFORGE_USR}.${SPONGEFORGE_USR} "${SPONGEFORGE_WORKDIR}"

EXPOSE	25565
VOLUME	"${SPONGEFORGE_WORKDIR}"
WORKDIR	"${SPONGEFORGE_WORKDIR}"
USER	${SPONGEFORGE_USR}

ENV	JVM_OPT_STRICT="-XX:+UseG1GC -XX:StringTableSize=1000003 -XX:MaxGCPauseMillis=50 -XX:+UseFastAccessorMethods -XX:+OptimizeStringConcat -XX:+AggressiveOpts -XX:+UseStringDeduplication -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./logs/OOM_Dump_last.hprof -XX:hashCode=5 -Dfile.encoding=UTF-8 -Dfml.debugExit=true"

ENTRYPOINT [ "entrypoint" ]

CMD	["-XX:MetaspaceSize=512M", "-XX:MaxMetaspaceSize=2G", "-Xms2G", "-Xmx4G"]
