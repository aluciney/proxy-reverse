FROM nginx
#add metadata
LABEL version="1.0.0"

RUN rm -rf /etc/nginx/conf.d

RUN rm -rf /usr/share/nginx/html

ADD /conf /etc/nginx/

EXPOSE 80
EXPOSE 443
