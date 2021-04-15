FROM quay.io/operator-framework/ansible-operator:v1.5.0

# OpenShift labels

LABEL name="ClearBlade Operator" \
      vendor="ClearBlade" \
      version="v0.0.1" \
      release="1" \
      summary="ClearBlade platform operator" \
      description="ClearBlade operator for deploying the ClearBlade platform to Kubernetes clusters"

# Ansible requirements

COPY requirements.yml ${HOME}/requirements.yml
RUN ansible-galaxy collection install -r ${HOME}/requirements.yml \
 && chmod -R ug+rwx ${HOME}/.ansible

# Licenses

COPY licenses /licenses

# Operator specific files

COPY watches.yaml ${HOME}/watches.yaml
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/

