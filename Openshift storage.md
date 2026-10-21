### OpenShift Persistent Storage: Complete Learning Roadmap

With your VMware-based OpenShift cluster of 3 control-plane nodes and 2 worker nodes, the best way to learn persistent storage is to build a practical storage lab, starting with local disks and progressing toward enterprise storage architectures.

The goal is not just to make a PersistentVolumeClaim (PVC) become `Bound`. You should learn how storage is provisioned, attached, mounted, secured, expanded, recovered, monitored, and made highly available for real applications—including payment systems and databases.

### 1\. Understand the OpenShift storage architecture

Application Pod

Database, payment service, or application

Mounts storage at a filesystem path

PersistentVolumeClaim (PVC)

The application's request for storage capacity and access mode

StorageClass + Provisioner

Defines how storage is created or selected

PersistentVolume (PV)

A Kubernetes resource representing a storage volume

Storage backend

Local disk, NFS, SAN, vSphere, or distributed storage

The core relationship is:

* PV: represents the storage resource available to the cluster.

* PVC: requests storage for an application.

* StorageClass: describes a storage provisioning policy.

* CSI driver: connects Kubernetes to a supported storage system.

* Provisioner: creates storage dynamically when supported; static provisioning instead uses administrator-created PVs.

* Reclaim policy: determines what happens to the underlying volume when its claim is released.

* Access mode: describes how a volume may be mounted by workloads. It does not, by itself, guarantee application-level concurrency or high availability.

Your first learning milestone is to understand these objects and how they interact before introducing more complex storage systems.

### 2\. Your lab architecture

Start with local persistent storage on the two worker nodes. You can add virtual disks through VMware and use them as dedicated storage devices.

VMware ESXi

Virtual machines and virtual disks

OpenShift cluster

3 control-plane nodes · 2 worker nodes

Worker 1

Dedicated virtual disk → local filesystem → local PV

Storage node A

Worker 2

Dedicated virtual disk → local filesystem → local PV

Storage node B

Test workload

Namespace → PVC → PV → pod → persistent test data

Important: local storage is tied to a particular node. If a pod uses a local PV on Worker 1 and that worker becomes unavailable, Kubernetes cannot simply mount that same disk on Worker 2. A local PV does not replicate data or provide storage high availability.

For the first exercise, use a disposable test application and a dedicated virtual disk—not a disk containing RHCOS system data.

### 3\. The three local storage solutions you should learn first

OpenShift 4.22 documents three principal approaches for node-local storage: Local Storage Operator (LSO), LVM Storage, and HostPath Provisioner (HPP). They solve related problems but have different provisioning models.

![Kubernetes: Application Storage and Persistent Volumes & Mechanisms of Volume Snapshots and Topology-aware Scheduling | Medium](https://images.openai.com/static-rsc-4/imk8iQ2MPlXcSn1pdIdtl74yaaagQ3E70DF-mCBM019Td73LXBbJ7uUfK6B1hAnh1KrJasByd2oYEx_SPBC5Tj4sC0DmMRsCWHFq0okbT06dLMr7cugn_Dahxw-rhF5NDpU1SrQt07KcekAwB45JU338zxpqrgSUIbadBv0NtmrobCFw-aSowuPLsiiUffPf?purpose=fullsize)

1\. Local Storage Operator (LSO)

Start here

Learn to discover dedicated disks, select devices, create `LocalVolume` and `LocalVolumeSet` resources, generate local PVs, and bind PVCs to those volumes.

Best for understanding the relationship between physical/virtual disks, nodes, PVs, and workload scheduling.

![LVM Linux: Complete Guide to the Logical Volume Manager](https://images.openai.com/static-rsc-4/XDiDvZ7HZgPRforsIAH_VOAZBIFCmtkKP84gCnmD_4H8HBbEqmGsQ51_Few1ynM5h60ZZEbsGVpyAOoSNq4eaWBxX2j-hlEbKHKWE-pyfJbrOhrucvvQh8z3c9RZwa4Fr0d8wxH-M0MJiP_c2Dm6uSYbfF1K2410k8GqQANXWcmvywb5tqJSJdL-tW3puCF9?purpose=fullsize)

2\. LVM Storage

Learn physical volumes, volume groups, logical volumes, the LVM Storage Operator, TopoLVM CSI, and dynamic PVC provisioning from configured local capacity.

Best for learning how to allocate logical volumes without manually creating a separate PV definition for each claim.

![StorageClass: local-path provider(EN) | by Albert Weng | Medium](https://images.openai.com/static-rsc-4/KoEbHNEeIoUYAXFA6M1v3ias1pMCPSj7WkXGUgBzo94UA_zQx627qbB5Z0726KW0R1SM3vJlmspR3AjBtO6HuVZpWxZggheLpZ7dqzDBMapdwOF8VuQsGTvnac7ZK-kh6oDiAKMLqMWbOHIrs94h66ZqCAgrZHsh7tzexMk73g0T1f1hvTpZg4NbL1BeaOyn?purpose=fullsize)

3\. HostPath Provisioner (HPP)

Learn directory-based storage on worker nodes, StorageClass configuration, and local filesystem paths.

Useful for understanding basic provisioning concepts and some lab environments. Prefer supported Red Hat storage solutions for production, and check the specific HPP implementation's support status.

My recommendation is to study them in this order: LSO → LVM Storage → HPP. You will first learn how Kubernetes represents a dedicated disk, then how to provision storage from a pool of local capacity.

### 4\. Your detailed, hands-on learning plan

This is a progressive 12-module curriculum. You can work through it in stages, validating each configuration before moving to the next.

Module 1 — Persistent storage fundamentals

Foundation · 1–2 days

Learn PV, PVC, StorageClass, provisioners, CSI, access modes, volume modes, binding, reclaim policies, and scheduling constraints.

Lab: Create a static PV and PVC; inspect `Available`, `Bound`, `Released`, and `Pending` states.

```bash
oc get pv
oc get pvc -A
oc get sc
oc describe pvc <claim-name> -n <namespace>
oc get events -n <namespace> --sort-by=.lastTimestamp
```

Module 2 — VMware virtual disks and node preparation

Foundation · 1–2 days

Add a separate virtual disk to each worker VM. Learn Linux disk discovery, device identification, partitioning, filesystems, mounting, and disk safety.

Lab: Identify the new disk using `lsblk`, `blkid`, `udevadm`, and `ls -l /dev/disk/by-id/`. Record which disk belongs to which worker.

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
sudo udevadm info --query=property --name=/dev/sdX
```

Replace `/dev/sdX` with the verified device. Do not format a disk until you have confirmed that it is the newly added, disposable disk.

Module 3 — Local Storage Operator

Core lab · 2–3 days

Install the operator, create its namespace and subscriptions through the supported installation method, inspect its custom resource definitions, and configure local devices.

Lab sequence:

* Install LSO from the OperatorHub or CLI.

* Create a `LocalVolume` resource for explicitly selected devices.

* Observe the resulting PVs and StorageClass.

* Create a PVC and a test pod.

* Verify node affinity and data persistence after deleting and recreating the pod.

Advanced lab: Create a `LocalVolumeSet` with restrictive device filters, then learn the difference between device discovery and PV provisioning.

Module 4 — LVM Storage Operator

Dynamic provisioning · 2–3 days

Learn how to create volume groups from eligible disks, configure the `LVMCluster` custom resource, create or inspect the generated StorageClass, and provision claims dynamically.

Lab: Create multiple PVCs from one local volume group, observe capacity allocation, exhaust a test pool, and troubleshoot pending claims.

Compare this approach with LSO: LSO discovers devices and creates PVs, while LVM Storage uses CSI to allocate logical volumes on demand.

Module 5 — Filesystem versus raw block storage

Storage interfaces · 1–2 days

Study `volumeMode: Filesystem` versus `volumeMode: Block`, filesystem types, mount options, ownership, permissions, SELinux, and OpenShift Security Context Constraints.

Lab: Mount a filesystem PVC at `/data`, write files, restart the pod, and verify persistence. Then use a raw block PVC with an application designed to consume a block device directly.

Module 6 — Network File System (NFS)

Shared file storage · 2 days

Build a separate Linux NFS server, configure exports and client access, create static NFS PVs, and test access from pods scheduled on both workers.

Lab: Deploy two application replicas with shared file storage. Learn UID/GID compatibility, permissions, network ACLs, NFS versions, and the distinction between a static NFS PV and a dynamic NFS provisioner.

Module 7 — VMware vSphere CSI storage

Virtual infrastructure integration · 2–4 days

Learn the vSphere CSI driver, storage policies, datastores, CNS volumes, controller permissions, VM topology, and dynamic provisioning.

Lab: Configure a supported vSphere-backed StorageClass and provision a PVC from a datastore. Test attach/detach behavior and review node and VM prerequisites.

This is especially relevant to your environment because your OpenShift nodes are virtual machines. Verify that your cluster installation type, vSphere version, and infrastructure configuration support the integration before starting.

Module 8 — OpenShift Data Foundation (ODF)

Distributed storage · 3–5 days

Learn the architecture of Ceph, the Rook operator, ODF components, block volumes, shared filesystems, object storage, device sets, failure domains, and storage capacity planning.

Lab: Build an ODF test deployment only after validating its prerequisites, supported topology, available disks, and resource requirements.

ODF is a major step up from node-local storage because it can provide distributed storage and replication. Your two-worker cluster may not meet the requirements for a particular ODF topology, so verify the current supported deployment configuration first.

Module 9 — Enterprise SAN and external storage

Enterprise integration · 2–4 days

Study Fibre Channel, iSCSI, multipathing, zoning, LUN masking, storage arrays, vendor CSI drivers, and file-storage appliances.

Lab: Simulate or configure an available supported backend, create a StorageClass, provision a claim, and test path failure and recovery. Never test destructive LUN operations on production storage.

Module 10 — Storage lifecycle and advanced operations

Administration · 2–3 days

Learn volume expansion, reclaim policies, PVC migration, StorageClass defaults, snapshots, clones, access-mode limitations, binding modes, and capacity monitoring.

Lab: Expand a claim, test `Retain` and `Delete` in a disposable environment, and restore application data using a supported snapshot or backup workflow.

Module 11 — Security, backup, disaster recovery, and troubleshooting

Operations · 3–4 days

Learn RBAC, namespace isolation, SELinux, encryption at rest and in transit where supported, storage credentials, backup tools, CSI snapshots, and application-consistent recovery.

Lab: Simulate a worker outage, a missing disk, a full volume, a permission error, a failed mount, and a lost PVC. Determine what can recover automatically and what requires restoring data.

Module 12 — Stateful applications and production design

Capstone · 3–5 days

Deploy a database using a StatefulSet, persistent claims, resource limits, probes, secrets, and a backup schedule. Compare local PVs, LVM-backed claims, NFS, and distributed storage.

Lab: Deploy a test PostgreSQL instance, write data, recreate the pod, perform a backup and restore, and document recovery limitations and service availability.

The duration is an estimate for guided practice, not a requirement to complete every module in a fixed number of days.

### 5\. Storage technologies you should ultimately master

OpenShift supports multiple storage backends, but they are not interchangeable. Learn which workload each technology is intended to serve.

| Storage technology        | Typical use                                  | Provisioning model                                   |
| ------------------------- | -------------------------------------------- | ---------------------------------------------------- |
| Local Storage Operator    | Dedicated disks on worker nodes              | Static PVs; operator-managed device discovery        |
| LVM Storage               | Logical volumes from local disks             | Dynamic                                              |
| HostPath Provisioner      | Local directories in supported lab scenarios | Depends on provisioner configuration                 |
| NFS                       | Shared files and application uploads         | Static or dynamic with a suitable provisioner        |
| VMware vSphere CSI        | Virtual disks backed by VMware storage       | Dynamic                                              |
| OpenShift Data Foundation | Distributed block, file, and object storage  | Dynamic capabilities depend on the storage interface |
| iSCSI / Fibre Channel     | SAN-backed block storage                     | Static or dynamic with an appropriate driver         |
| Vendor CSI drivers        | Enterprise storage arrays and appliances     | Driver-dependent                                     |
| Cloud block storage       | AWS EBS, Azure Disk, Google Persistent Disk  | Dynamic                                              |
| Cloud file storage        | AWS EFS, Azure Files, Google Filestore       | Dynamic where supported                              |

OpenShift's storage documentation covers these backends, their provisioning models, and the relevant CSI integrations. The exact availability and support status depend on your OpenShift release and infrastructure.

Two important distinctions:

* Block storage is generally suited to databases and filesystems that need a disk-like device.

* File storage is generally suited to shared directories, application uploads, and workloads that need filesystem access from multiple pods.

Object storage is different: applications usually access it through an API rather than mounting it as a conventional PVC.

### 6\. Essential configurations to master for every storage type

Use this checklist throughout the course. The objective is to learn these concepts across different backends, not just configure one storage class.

### Storage mastery checklist

0/20

Provisioning

Static PV creation and binding

Dynamic provisioning with StorageClass

Immediate versus WaitForFirstConsumer binding

Default StorageClass and class selection

Capacity requests and storage quotas

Volume behavior

ReadWriteOnce, ReadOnlyMany, ReadWriteMany, and ReadWriteOncePod

Filesystem versus raw block volume mode

Node affinity and topology-aware scheduling

Volume attachment and mount lifecycle

Reclaim policies: Retain and Delete

Operations

PVC expansion and filesystem resizing

Snapshot and clone support

Safe volume reuse and deletion

Storage capacity monitoring

Backup, restore, and application consistency

Security and resilience

RBAC and namespace isolation

UID/GID, SELinux, and filesystem permissions

Encryption and credential management

Node failure and storage failure testing

Recovery objectives and disaster recovery

Reset checklistCopy checklist

Remember that access modes describe supported access semantics; they do not automatically make an application safe for concurrent writers. Snapshot support, expansion, and cloning are also backend- and driver-dependent.

### 7\. Your first practical lab: Local Storage Operator

Let's begin with a controlled exercise on your existing cluster.

### Step 1 — Inspect your cluster

Run these commands from a workstation with authenticated `oc` access:

```bash
oc whoami
oc get clusterversion
oc get nodes -o wide
oc get storageclass
oc get pv
oc get pvc -A
oc get csv -A
```

Check that both worker nodes are `Ready` and note any existing storage classes. Do not change the default storage class yet.

### Step 2 — Add dedicated virtual disks

In VMware vSphere or your ESXi management interface:

* Identify both OpenShift worker VMs.

* Add a separate, disposable virtual disk to each worker.

* Start or rescan the VMs as required.

* Verify that each disk appears inside the correct node.

* Record each device's size, model, serial number, and stable `/dev/disk/by-id/` path.

Do not use the control-plane disks or the operating-system disks for this exercise.

### Step 3 — Install the Local Storage Operator

Use the OpenShift web console:

* Open Ecosystem → Operators → OperatorHub (menu labels may vary slightly by release).

* Search for Local Storage.

* Select the Red Hat Local Storage Operator.

* Install it into the `openshift-local-storage` namespace, following the installation defaults and the documentation for your release.

* Verify that the operator is installed and healthy.

You can also inspect the operator and its API resources from the CLI:

```bash
oc get pods -n openshift-local-storage
oc get csv -n openshift-local-storage
oc get crd | grep local.storage.openshift.io
```

If the cluster cannot reach the required image registries, verify that the operator images and dependencies are available through your organization's approved mirroring process.

### Step 4 — Configure local storage

For your first pass, use the `LocalVolume` resource with explicitly selected, dedicated disks. Learn these fields:

* `storageClassDevices`

* `devicePaths`

* `storageClassName`

* `volumeMode`

* `fsType`

* `nodeSelector`

Use the official [OpenShift 4.22 Storage guide](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22/html-single/storage/index?utm_source=chatgpt.com), particularly Chapter 5, as the configuration reference.

After reconciliation, inspect the generated PVs:

```bash
oc get pv -o wide
oc get sc
oc describe pv <pv-name>
```

Confirm that each PV points to the intended worker and disk. A local storage configuration does not automatically create replicated storage.

### Step 5 — Create a PVC

Create a test namespace and a claim that uses the StorageClass created for your local volumes.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-test-pvc
  namespace: storage-lab
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  storageClassName: REPLACE_WITH_YOUR_LOCAL_STORAGE_CLASS
  resources:
    requests:
      storage: 5Gi
```

Create the namespace and claim:

```bash
oc new-project storage-lab
oc apply -f local-pvc.yaml
oc get pvc -n storage-lab -w
```

Replace the StorageClass placeholder with the actual class name. The request must fit a suitable available PV; otherwise, the claim will remain pending.

### Step 6 — Mount the claim in a test pod

Use an approved container image already available in your environment. The pod should mount the PVC at `/data`, write a test file, and read it back.

For example, the container command can create a file containing a timestamp and then wait, allowing you to inspect it:

```bash
date > /data/storage-test.txt
cat /data/storage-test.txt
```

Run these commands inside the container using `oc exec` or as the command for a temporary test workload. If your chosen image does not include `date` or a shell, adapt the test to the tools available in that image.

Then:

* Delete the test pod.

* Recreate it using the same PVC.

* Read the file again.

* Identify which worker the pod is scheduled on.

* Review the PV's node affinity.

Success criterion: the file survives pod deletion and recreation, and the pod is scheduled where the local volume is accessible.

Do not delete the PVC or PV during this first test. Those actions can affect the underlying data depending on the storage configuration.

### 8\. Official documentation to keep as your reference

![Red Hat OpenShift Container Platform Standard](https://images.openai.com/static-rsc-4/eArcrbSwINaiIZrHJ4hYB4s56J81Bmb3fVZwaaAFXZq0OqBITIaaUV4XGzaE4SmDJjYOVEDMJ6jvSry7-75SWnupH9ya0Noe9PPLwWK8MX_DTjdnAKU4e_ReTWJVSYHIkfzc_h8vfkT47fE7znoh-GIcdWwPkmZMuhP9C-M58fIqHMpk60SI9ZfVxo9vFUtl?purpose=fullsize)

[OpenShift 4.22 Storage guide](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22/html-single/storage/index?utm_source=chatgpt.com)

Main reference for PVs, PVCs, StorageClasses, LSO, LVM Storage, NFS, and storage backends.

![Installing OpenShift Data Foundation v4.10 on bare metal with local storage | by Melih Can Ulug | Medium](https://images.openai.com/static-rsc-4/FTYSedWnUTlA6XgsAFSx2g5C3I0vMEpAo6qG141-ZBxWUE-Im7BijUUFJzqwBznZVajdhwX3kYBwJKlt96fryIEsN38ZWwRyPuEIf-HRSvOle8yrm9ZOJqbqB0g55j9tS70wdcLcwsy1PlgqQWcjfCWlewPwwDZ_0uxO7sLqB3-j3bOOzg9lD7bdTQv4ZnZW?purpose=fullsize)

[Local storage configuration](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22/html/storage/configuring-persistent-storage?utm_source=chatgpt.com)

Use the local-storage chapter to study disk discovery, LocalVolume resources, and local PV provisioning.

![The Complete Kubernetes Storage Guide: From Basics to Production Mastery. Part2/3 | by Salwan Mohamed | Medium](https://images.openai.com/static-rsc-4/2Jk_ZSYwywGuXdmOK-366mTPs2QNPa0PsEZ3OSxOVnw7dg2x-k5KOoKHMlQpe9kEMvNSrUCSvMI25BX-6EJXT69kPCnyFXTD_aVHrGcsETgVeaHqhkNhe-IYcv6WvEx7RiMg-zdMnlAl1jFdDcTrfx-YLANLnvWtJeqeMdGa1aNqB8OcBVthzgdA5VHJ2rVA?purpose=fullsize)

[Container Storage Interface documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22/html/storage/using-container-storage-interface-csi?utm_source=chatgpt.com)

Understand CSI controller and node components, volume lifecycle operations, and storage driver integration.

### 9\. Before we start the first lab

I want to tailor the actual installation steps to your existing cluster rather than give you commands for the wrong environment.

### Your OpenShift storage lab

Select the options that match your environment.

1\. OpenShift version

OpenShift 4.22

OpenShift 4.21

Other version / not sure

2\. VMware environment

VMware vSphere managed through vCenter

Standalone ESXi host

Other / not sure

3\. Have you added dedicated virtual disks to the workers?

No, not yet

Yes, disks are attached

Unsure whether the disks are visible to RHCOS

4\. Preferred configuration method

CLI (`oc`) and YAML — preferred for learning

OpenShift web console

Both CLI and web console

Prepare my first local storage lab

My recommended starting point is LSO with one dedicated disk per worker, followed by a test PVC and pod. Once you can explain exactly why that pod is tied to one node and what happens when the node fails, you will have the foundation to move into LVM Storage, shared NFS, vSphere CSI, and distributed storage with a much clearer understanding of the trade-offs.
