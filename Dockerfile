FROM python:3.10-slim AS build

WORKDIR /app

#COPY docker/install_build.sh /app/
#RUN sh install_build.sh

COPY pyproject.toml poetry.lock /app/

COPY stpm stpm

# Install poetry
RUN python -m pip install poetry virtualenv

ENV VIRTUAL_ENV /app/venv

# Create & activate virtualenv
RUN virtualenv $VIRTUAL_ENV
ENV PATH $VIRTUAL_ENV/bin:$PATH

# Install python dependencies
RUN poetry install --no-dev

FROM python:3.10-slim AS stpm

ENV PYTHONUNBUFFERED 1
ENV PIP_NO_CACHE_DIR off

# Passing the -d /app will set that as the home dir & chown it
RUN useradd -r -U -m -d /app stpm

WORKDIR /app

#COPY --chown=stpm:stpm docker/install_runtime.sh /app/
#RUN sh install_runtime.sh

COPY --chown=stpm:stpm --from=build /app /app

ENV VIRTUAL_ENV /app/venv
ENV PATH $VIRTUAL_ENV/bin:$PATH

USER stpm

CMD ["stpm", "run"]