# https://github.com/openid-certification/oidctest
ARG base_image
FROM $base_image

ENV SUBDIR /usr/local/src/oidf/oidc_op
ENV INITDIR ${SUBDIR}/init

RUN mkdir ${INITDIR};

COPY start.sh ${SUBDIR}/
COPY assigned_ports.json ${INITDIR}/
COPY entities ${INITDIR}/entities/

RUN rm ${SUBDIR}/static/jwks_60003.json; \
  chmod +x start.sh;

ENTRYPOINT ["./start.sh"]

EXPOSE 60000-60010