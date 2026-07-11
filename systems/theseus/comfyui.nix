{ flakes, pkgs, lib, ... }:

{
    imports = [
        flakes.nixified-ai.nixosModules.comfyui
    ];

    services.comfyui = let
        overlay = flakes.nixified-ai.overlays.comfyui;

        versionOverlay = final: prev: let
            python = final.python3;
            pp = python.pkgs;

            deps = let
                build = pname: version: hash: python.pkgs.buildPythonPackage {
                        inherit pname version;

                        src = final.fetchPypi {
                            inherit pname version hash;
                        };

                        pyproject = true;
                        build-system = [ pp.setuptools ];
                    };
            in {
                comfyui-frontend-package = build
                    "comfyui_frontend_package"
                    "1.27.7"
                    "sha256-feBRoG6PLORaMEi1hIHzhfPtPeEpK4NSkxQR2iqxmUg=";

                comfyui-workflow-templates = build
                    "comfyui_workflow_templates"
                    "0.1.91"
                    "sha256-bhxabQ7UC+19Sgqwdop71HyFyow/8t4q+CwT4mZDjwQ=";

                comfyui-embedded-docs = build
                    "comfyui_embedded_docs"
                    "0.2.6"
                    "sha256-ild/PuIWvo3NbAjpZYxvJX/7np6B9A8NNt6bSZJJdWo=";
            };

        in {
            comfyuiPackages = prev.comfyuiPackages // {
                comfyui-unwrapped = let
                    orig = prev.comfyuiPackages.comfyui-unwrapped;
                in
                    orig.overridePythonAttrs (oa: {
                        src = pkgs.fetchFromGitHub {
                            owner = "comfyanonymous";
                            repo = "ComfyUI";
                            rev = "v0.3.62";
                            hash = "sha256-X2lvOJR6GMhUME/ADhNRMpGAo7EtG60h+Q1imC10LBM=";
                        };

                        dependencies = oa.dependencies ++ [
                            deps.comfyui-frontend-package
                            deps.comfyui-workflow-templates
                            deps.comfyui-embedded-docs
                            pp.av
                            pp.pydantic
                            pp.pydantic-settings
                            pp.alembic
                            pp.sqlalchemy
                        ];
                    });
            };
        };

        cudaPkgs = import pkgs.path {
            inherit (pkgs) system;

            overlays = [ overlay versionOverlay ];

            config = {
                allowUnfree = true;
                cudaSupport = true;
                cudaCapabilities = [ "7.0" ];
            };
        };

        nodes = let
            mkNode = cudaPkgs.comfyui.mkComfyUICustomNode;
            pp = cudaPkgs.python3.pkgs;
        in {
            gguf = mkNode {
                pname = "comfyui-gguf";
                version = "unstable-2025-09-14";
                pyproject = false;

                src = pkgs.fetchFromGitHub {
                    owner = "city96";
                    repo = "ComfyUI-GGUF";
                    rev = "be2a08330d7ec232d684e50ab938870d7529471e";
                    hash = "sha256-NtpoLwlcMXeVCffZmQeHKDl9hM6gCBprdnhHblrWQ20=";
                };

                propagatedBuildInputs = [
                    pp.gguf
                ];
            };

            gguf-node = mkNode {
                pname = "gguf-node";
                version = "0.0.72";
                pyproject = false;

                src = pkgs.fetchFromGitHub {
                    owner = "calcuis";
                    repo = "gguf";
                    rev = "0.0.72";
                    hash = "sha256-by6cZOe8m12Efdd491k78NNx8iRn765EcWPV9SILyzc=";
                };

                propagatedBuildInputs = [
                    pp.gguf
                ];
            };

            image-filters = mkNode {
                pname = "comfyui-image-filters";
                version = "0";
                pyproject = false;

                src = pkgs.fetchFromGitHub {
                    owner = "spacepxl";
                    repo = "ComfyUI-Image-Filters";
                    rev = "f73e586470e0d65a7372b328d4bccbabfc94c180";
                    hash = "sha256-M2i+o+rFKn06+j75cRhzjhBVnFicb3I8do2x2Z1GrtM=";
                };

                propagatedBuildInputs = [
                    pp.opencv-python-headless
                ];
            };

            joycaption = mkNode {
                pname = "comfyui-joycaption";
                version = "unstable-2025-05-15";
                pyproject = false;

                src = pkgs.fetchFromGitHub {
                    owner = "fpgaminer";
                    repo = "joycaption_comfyui";
                    rev = "1ef4c8cd817f0c2386e6b188721f1fecf79121ae";
                    hash = "sha256-QgJv+B71vXH8qrzA7RCdIu94FKPnQx2I5sH5xfE2Qug=";
                };

                dontBuild = true;

                propagatedBuildInputs = [
                    pp.transformers
                    pp.torchvision
                    pp.huggingface-hub
                    pp.accelerate
                    pp.bitsandbytes
                ];
            };

            distributed = mkNode {
                pname = "comfyui-distributed";
                version = "1.1.0";
                pyproject = false;

                src = pkgs.fetchFromGitHub {
                    owner = "robertvoy";
                    repo = "ComfyUI-Distributed";
                    rev = "v1.1.0";
                    hash = "sha256-iWMulnvOgYd7LMkMguQbWs2iUBCz/55djanawwz+PyU=";
                };
            };
        };
    in {
        enable = true;
        package = cudaPkgs.comfyui;
        host = "0.0.0.0";
        models = builtins.attrValues pkgs.nixified-ai.models;

        extraFlags = [
            "--preview-method" "auto"
            "--enable-cors-header"
        ];

        customNodes = let n = nodes; in [
            n.gguf
            n.gguf-node
            n.joycaption
            #n.image-filters
            n.distributed
        ];
    };
}