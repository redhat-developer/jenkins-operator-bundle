import os
import time
import logging
from behave import given, when, then
from datetime import date
from pyshould import should
from kubernetes import config, client
from smoke.features.steps.openshift import Openshift
from smoke.features.steps.project import Project

'''
If we need to install an operator manually using the cli 
- ensure your catalog source is installed
- create an OperatorGroup
- create the Subscription object
'''

# Path to the yaml files
scripts_dir = os.getenv('OUTPUT_DIR')
catalogsource = './smoke/samples/catalog-source.yaml'
operatorgroup = os.path.join(scripts_dir,'operator-group.yaml')
subscription = os.path.join(scripts_dir,'subscription.yaml')

# variables needed to get the resource status
current_project = ''
config.load_kube_config()
v1 = client.CoreV1Api()
oc = Openshift()

podStatus = {}


# STEP


@given(u'Project "{project_name}" is used')
def given_project_is_used(context, project_name):
    project = Project(project_name)
    global current_project
    current_project = project_name
    context.current_project = current_project
    context.oc = oc
    if not project.is_present():
        print("Project is not present, creating project: {}...".format(project_name))
        project.create() | should.be_truthy.desc(
            "Project {} is created".format(project_name))
    print("Project {} is created!!!".format(project_name))
    context.project = project


# STEP
@given(u'Project [{project_env}] is used')
def given_namespace_from_env_is_used(context, project_env):
    env = os.getenv(project_env)
    assert env is not None, f"{project_env} environment variable needs to be set"
    print(f"{project_env} = {env}")
    given_project_is_used(context, env)


@given(u'we have a openshift cluster')
def loginCluster(context):
    print("Using [{}]".format(current_project))


@when(u'we create the catalog source using catalog-source.yaml')
def createCatalogsource(context):
    res = oc.oc_create_from_yaml(catalogsource)
    print(res)


@then(u'we create operator group using operator-group.yaml')
def createOperatorgroup(context):
    res = oc.oc_create_from_yaml(operatorgroup)
    print(res)


@then(u'we create subscription using subscriptions.yaml')
def createSubsObject(context):
    res = oc.oc_create_from_yaml(subscription)
    print(res)


@then(u'we check for the csv and csv version')
def verifycsv(context):
    print('---> Getting the resources')
    time.sleep(90)
    if not 'jenkins-operator' in oc.search_resource_in_namespace('csv','jenkins-operator',current_project):
        raise AssertionError
    else:
        res = oc.search_resource_in_namespace('csv','jenkins-operator',current_project)
        print(res)


@then(u'we check for the operator group')
def verifyoperatorgroup(context):
    if not 'jenkins-operator' in oc.search_resource_in_namespace('operatorgroup','jenkins-operator',current_project):
        raise AssertionError
    else:
        res = oc.search_resource_in_namespace('operatorgroup','jenkins-operator',current_project)
        print(res)


@then(u'we check for the subscription')
def verifysubs(context):
    if not 'jenkins-operator' in oc.search_resource_in_namespace('subs','jenkins-operator',current_project):
        raise AssertionError
    else:
        res = oc.search_resource_in_namespace('subs','jenkins-operator',current_project)
        print(res)


@then(u'we check for the operator pod')
def verifyoperatorpod(context):
    print('---> checking operator pod status')
    context.v1 = v1
    pods = v1.list_namespaced_pod(current_project)
    for i in pods.items:
        print("Getting pod list")
        podStatus[i.metadata.name] = i.status.phase
        print('---> Validating...')
        if not i.metadata.name in oc.search_pod_in_namespace(i.metadata.name,current_project):
            raise AssertionError

    print('waiting to get pod status')
    time.sleep(60)
    for pod in podStatus.keys():
        status = podStatus[pod]
        if 'Running' in status:
            print(pod)
            print(podStatus[pod])
        else:
            raise AssertionError
