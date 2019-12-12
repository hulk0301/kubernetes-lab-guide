# kubernetes-lab-guide

## Lab content

The lab content can be found here:

- [Basic kubernetes lab](./lab/lab-1.md)

## Solution

The solution(kubernetes manifests) can be found [here](./solution/).

## Build LAB PDF

To build the LAB pdf check the [build](scripts/build.sh) script.

Alternative: Use docker if you don't want to install node and mddpf on your local machine.

```sh
docker run -v $(pwd):/workspace -w /workspace --entrypoint /workspace/scripts/build.sh node:13-alpine
```
