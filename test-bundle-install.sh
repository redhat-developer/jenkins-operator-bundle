#!/bin/sh

OSFLAG="unknown"
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   OSFLAG='LINUX'
elif [[ "$unamestr" == 'Darwin' ]]; then
   OSFLAG='OSX'
fi

#-----------------------------------------------------------------------------
# Global Variables
#-----------------------------------------------------------------------------
export V_FLAG=-v
export OUTPUT_DIR=$(pwd)/out
export LOGS_DIR=${OUTPUT_DIR}/logs
export GOLANGCI_LINT_BIN=${OUTPUT_DIR}/golangci-lint
export PYTHON_VENV_DIR=${OUTPUT_DIR}/venv3
# -- Variables for smoke tests
export TEST_SMOKE_ARTIFACTS=/tmp/artifacts

# -- Setting up the venv
python3 -m venv ${PYTHON_VENV_DIR}
${PYTHON_VENV_DIR}/bin/pip install --upgrade setuptools
${PYTHON_VENV_DIR}/bin/pip install --upgrade pip
# -- Generating a new namespace name
echo "test-namespace-$(uuidgen | tr '[:upper:]' '[:lower:]' | head -c 8)" > ${OUTPUT_DIR}/test-namespace
export TEST_NAMESPACE=$(cat ${OUTPUT_DIR}/test-namespace)
echo "Assigning value to varibale TEST_NAMESPACE:"${TEST_NAMESPACE}

# -- Do clean up & create namespace
echo "Starting cleanup"
echo $(kubectl delete namespace ${TEST_NAMESPACE} --timeout=45s --wait)
echo $(kubectl create namespace ${TEST_NAMESPACE})
$(mkdir -p ${LOGS_DIR}/smoke)
$(mkdir -p ${OUTPUT_DIR}/smoke-tests)
export TEST_SMOKE_OUTPUT_DIR=${OUTPUT_DIR}/smoke-tests
echo "Logs directory created at "{$LOGS_DIR/smoke}

# -- Set namespace for subscription.yaml & operator-group.yaml file , set the TEST_NAMESPACE as current project
if [[ '${OSFLAG}'=='OSX' ]];then
    $(sed -i '' 's|PROJECT|'${TEST_NAMESPACE}'|g' smoke/samples/subscription.yaml)
	$(sed -i '' 's|PROJECT|'${TEST_NAMESPACE}'|g' smoke/samples/operator-group.yaml)
else
    $(sed -i 's|PROJECT|'${TEST_NAMESPACE}'|g' ./smoke/samples/subscription.yaml)
	$(sed -i 's|PROJECT|'${TEST_NAMESPACE}'|g' ./smoke/samples/operator-group.yaml)
fi

# -- Setting the project
echo $(oc project ${TEST_NAMESPACE})

# -- Trigger the test
echo "Starting local Jenkins instance"
${PYTHON_VENV_DIR}/bin/pip install -q -r requirements.txt
echo "Running smoke tests"
TEST_NAMESPACE=${TEST_NAMESPACE}
${PYTHON_VENV_DIR}/bin/behave --junit --junit-directory ${TEST_SMOKE_OUTPUT_DIR} --no-capture --no-capture-stderr smoke/features

## Reset the subscription.yaml & operator-group.yaml file
if [[ '${OSFLAG}'=='OSX' ]];then
    $(sed -i '' 's|'${TEST_NAMESPACE}'|PROJECT|g' smoke/samples/subscription.yaml)
	$(sed -i '' 's|'${TEST_NAMESPACE}'|PROJECT|g' smoke/samples/operator-group.yaml)
else
    $(sed -i 's|'${TEST_NAMESPACE}'|PROJECT|g' ./smoke/samples/subscription.yaml)
	$(sed -i 's|'${TEST_NAMESPACE}'|PROJECT|g' ./smoke/samples/operator-group.yaml)
fi
echo "Logs collected at "${TEST_SMOKE_OUTPUT_DIR}
