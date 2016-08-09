load("//bzl:invoke.bzl", "invoke")

EXECUTABLE = Label("@com_github_google_protobuf//:protoc")

def protoc(spec = [],
           name,
           gendir = "$(GENDIR)",
           ctx = None,
           protos = [],
           protoc_executable=EXECUTABLE,
           protobuf_plugin_executable=None,
           protobuf_plugin_options=[],
           grpc_plugin_executable=None,
           grpc_plugin_options=[],
           imports = [],
           args = [],
           testonly = False,
           visibility = None,
           with_grpc = False,
           verbose = False,
           descriptor_set = None,
           execute = True):

  if protoc_executable == None:
    protoc_executable = EXECUTABLE

  self = {
    "name": name,
    "gendir": gendir,
    "protos": protos,
    "protoc": protoc_executable,
    "protobuf_plugin": protobuf_plugin_executable,
    "protobuf_plugin_options": protobuf_plugin_options,
    "grpc_plugin": grpc_plugin_executable,
    "grpc_plugin_options": grpc_plugin_options,
    "imports": imports,
    "testonly": testonly,
    "visibility": visibility,
    "args": args,
    "with_grpc": with_grpc,
    "descriptor_set": descriptor_set,
    "tools": [],
    "cmd": [],
    "outs": [],
    "hdrs": [],
    "verbose": verbose,
    "execute": execute,
  }

  for lang in spec:
    invoke("build_generated_files", lang, self, ctx)
    invoke("build_tools", lang, self, ctx)
    invoke("build_imports", lang, self, ctx)
    invoke("build_protoc_out", lang, self, ctx)
    invoke("build_protobuf_invocation", lang, self, ctx)
    invoke("build_protoc_arguments", lang, self, ctx)

    if self["with_grpc"]:
      if not hasattr(lang, "grpc"):
        fail("Language %s does not support gRPC" % lang.name)
        invoke("build_grpc_out", lang, self, ctx)
        invoke("build_grpc_invocation", lang, self, ctx)

    invoke("build_protoc_command", lang, self, ctx)

  if execute:
    if ctx:
      invoke("execute_protoc_rule", self, ctx)
    else:
      invoke("execute_protoc_genrule", self)

  for src in self["outs"]:
    if src.endswith(".h"):
      self["hdrs"] = [src]

  return struct(**self)