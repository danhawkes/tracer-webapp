FROM nodesource/trusty:0.12.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates

# Create and run as non-root user
RUN useradd -m tracer
RUN mkdir /tracer & chown tracer /tracer
WORKDIR /tracer
USER tracer

# TODO: Wait for build-time environment variables
# https://github.com/docker/docker/pull/9176
# In interim, copy paste in env required by web and app builds, e.g.
# 	
# ENV WEB_URL https://localhost:9000
# ENV DB_URL https://localhost:9001
# etc…

# Clone + build
RUN git clone https://github.com/danhawkes/tracer-app.git
RUN cd tracer-app && npm install
RUN git clone https://github.com/danhawkes/tracer-web.git
RUN cd tracer-web && npm install

# Move app build products to where static server will find them
RUN cp -r tracer-app/build tracer-web/build/static

WORKDIR tracer-web/build
EXPOSE 9001

# Run this in shell form otherwise it doesn't get signals
ENTRYPOINT node -e "require('./server')().start();"
