defmodule ReleasePing.Fixtures do
  use ExMachina

  defmodule GithubResponses do
    def rate_limit_json do
      """
      {
        "resources": {
          "core": {
            "limit": 5000,
            "remaining": 4823,
            "reset": 1503961236
          },
          "search": {
            "limit": 30,
            "remaining": 30,
            "reset": 1503960352
          },
          "graphql": {
            "limit": 5000,
            "remaining": 4999,
            "reset": 1503960244
          }
        },
        "rate": {
          "limit": 5000,
          "remaining": 4823,
          "reset": 1503961236
        }
      }
      """
    end

    def new_releases_json(1) do
      """
      {
        "data": {
          "rateLimit": {
            "cost": 1,
            "limit": 5000,
            "nodeCount": 10,
            "remaining": 4993,
            "resetAt": "2017-08-28T07:27:53Z"
          },
          "repository": {
            "tags": {
              "edges": [
                {
                  "cursor": "OTI=",
                  "node": {
                    "id": "MDM6UmVmMzc0OTI3Ok9UUC0xOS4zLjYuMg==",
                    "name": "OTP-19.3.6.2",
                    "target": {
                      "id": "MDM6VGFnMzc0OTI3OjMxNDBmNDVhOGM5ZDE2OWQ4YzNmMWMwNWQxZjc4YTM1NTMzNzk0MGM=",
                      "message": "=== OTP-19.3.6.2 ===\\n\\nChanged Applications:\\n- erts-8.3.5.2\\n\\nUnchanged Applications:\\n- asn1-4.0.4\\n- common_test-1.14\\n- compiler-7.0.4\\n- cosEvent-2.2.1\\n- cosEventDomain-1.2.1\\n- cosFileTransfer-1.2.1\\n- cosNotification-1.2.2\\n- cosProperty-1.2.1\\n- cosTime-1.2.2\\n- cosTransactions-1.3.2\\n- crypto-3.7.4\\n- debugger-4.2.1\\n- dialyzer-3.1.1\\n- diameter-1.12.2\\n- edoc-0.8.1\\n- eldap-1.2.2\\n- erl_docgen-0.6.1\\n- erl_interface-3.9.3\\n- et-1.6\\n- eunit-2.3.2\\n- gs-1.6.2\\n- hipe-3.15.4\\n- ic-4.4.2\\n- inets-6.3.9\\n- jinterface-1.7.1\\n- kernel-5.2\\n- megaco-3.18.1\\n- mnesia-4.14.3\\n- observer-2.3.1\\n- odbc-2.12\\n- orber-3.8.2\\n- os_mon-2.4.2\\n- otp_mibs-1.1.1\\n- parsetools-2.1.4\\n- percept-0.9\\n- public_key-1.4\\n- reltool-0.7.3\\n- runtime_tools-1.11.1\\n- sasl-3.0.3\\n- snmp-5.2.5\\n- ssh-4.4.2\\n- ssl-8.1.3\\n- stdlib-3.3\\n- syntax_tools-2.1.1\\n- tools-2.9.1\\n- typer-0.9.12\\n- wx-1.8\\n- xmerl-1.3.14\\n",
                      "tagger": {
                        "name": "Erlang/OTP",
                        "date": "2017-07-25T09:47:11+02:00"
                      }
                    }
                  }
                },
                {
                  "cursor": "OTM=",
                  "node": {
                    "id": "MDM6UmVmMzc0OTI3Ok9UUC0yMC4wLXJjMQ==",
                    "name": "OTP-20.0-rc1",
                    "target": {
                      "id": "MDM6VGFnMzc0OTI3OjQ5YTlmNmFmNWQ5Njc3OTJjZjI1YTc1ZTA4ZWM5M2U2ZTE2MjM4MDM=",
                      "message": "=== OTP-20.0 ===\\n\\nChanged Applications:\\n- asn1-5.0\\n- common_test-1.15\\n- compiler-7.1\\n- cosProperty-1.2.2\\n- crypto-4.0\\n- debugger-4.2.2\\n- dialyzer-3.2\\n- diameter-1.12.3\\n- edoc-0.9\\n- erl_docgen-0.7\\n- erl_interface-3.10\\n- erts-9.0\\n- eunit-2.3.3\\n- hipe-3.16\\n- inets-6.3.9\\n- jinterface-1.8\\n- kernel-5.3\\n- megaco-3.18.2\\n- mnesia-4.15\\n- observer-2.4\\n- orber-3.8.3\\n- parsetools-2.1.5\\n- public_key-1.4.1\\n- runtime_tools-1.12\\n- sasl-3.0.4\\n- ssh-4.5\\n- ssl-8.2\\n- stdlib-3.4\\n- syntax_tools-2.1.2\\n- tools-2.10\\n- wx-1.8.1\\n- xmerl-1.3.14\\n\\nUnchanged Applications:\\n- cosEvent-2.2.1\\n- cosEventDomain-1.2.1\\n- cosFileTransfer-1.2.1\\n- cosNotification-1.2.2\\n- cosTime-1.2.2\\n- cosTransactions-1.3.2\\n- eldap-1.2.2\\n- et-1.6\\n- ic-4.4.2\\n- odbc-2.12\\n- os_mon-2.4.2\\n- otp_mibs-1.1.1\\n- reltool-0.7.3\\n- snmp-5.2.5\\n",
                      "tagger": {
                        "name": "Raimo Niskanen",
                        "date": "2017-05-05T13:13:43+02:00"
                      }
                    }
                  }
                },
                {
                  "cursor": "OTQ=",
                  "node": {
                    "id": "MDM6UmVmMzc0OTI3Ok9UUC0yMC4wLXJjMg==",
                    "name": "OTP-20.0-rc2",
                    "target": {
                      "id": "MDM6VGFnMzc0OTI3OjE4NjJjZDE4MWJhNWE1MDBmNmRlYjI1NGZkMDg2NDkyMjNkYTAzZWI=",
                      "message": "Release Candidate 2\\n",
                      "tagger": {
                        "name": "Hans Nilsson",
                        "date": "2017-05-31T16:15:39+02:00"
                      }
                    }
                  }
                },
                {
                  "cursor": "OTU=",
                  "node": {
                    "id": "MDM6UmVmMzc0OTI3Ok9UUC0yMC4w",
                    "name": "OTP-20.0",
                    "target": {
                      "id": "MDM6VGFnMzc0OTI3OjI3MjM0NDdmYThmZGEzNjliOWUzN2M5ZDI4ZjBlNmEzNWIwZWJlOWM=",
                      "message": "=== OTP-20.0 ===\\n\\nChanged Applications:\\n- asn1-5.0\\n- common_test-1.15\\n- compiler-7.1\\n- cosProperty-1.2.2\\n- crypto-4.0\\n- debugger-4.2.2\\n- dialyzer-3.2\\n- diameter-2.0\\n- edoc-0.9\\n- erl_docgen-0.7\\n- erl_interface-3.10\\n- erts-9.0\\n- eunit-2.3.3\\n- hipe-3.16\\n- inets-6.4\\n- jinterface-1.8\\n- kernel-5.3\\n- megaco-3.18.2\\n- mnesia-4.15\\n- observer-2.4\\n- orber-3.8.3\\n- parsetools-2.1.5\\n- public_key-1.4.1\\n- reltool-0.7.4\\n- runtime_tools-1.12\\n- sasl-3.0.4\\n- snmp-5.2.6\\n- ssh-4.5\\n- ssl-8.2\\n- stdlib-3.4\\n- syntax_tools-2.1.2\\n- tools-2.10\\n- wx-1.8.1\\n- xmerl-1.3.15\\n\\nUnchanged Applications:\\n- cosEvent-2.2.1\\n- cosEventDomain-1.2.1\\n- cosFileTransfer-1.2.1\\n- cosNotification-1.2.2\\n- cosTime-1.2.2\\n- cosTransactions-1.3.2\\n- eldap-1.2.2\\n- et-1.6\\n- ic-4.4.2\\n- odbc-2.12\\n- os_mon-2.4.2\\n- otp_mibs-1.1.1\\n",
                      "tagger": {
                        "name": "Erlang/OTP",
                        "date": "2017-06-21T10:53:21+02:00"
                      }
                    }
                  }
                },
                {
                  "cursor": "OTY=",
                  "node": {
                    "id": "MDM6UmVmMzc0OTI3Ok9UUC0yMC4wLjE=",
                    "name": "OTP-20.0.1",
                    "target": {
                      "id": "MDM6VGFnMzc0OTI3OmFiNTgzYTc3MGZmNTFkZjE2NmY1NTFhZjczYWU5MmFhNTg3ZjM0MjA=",
                      "message": "=== OTP-20.0.1 ===\\n\\nChanged Applications:\\n- common_test-1.15.1\\n- erts-9.0.1\\n- runtime_tools-1.12.1\\n- stdlib-3.4.1\\n- tools-2.10.1\\n\\nUnchanged Applications:\\n- asn1-5.0\\n- compiler-7.1\\n- cosEvent-2.2.1\\n- cosEventDomain-1.2.1\\n- cosFileTransfer-1.2.1\\n- cosNotification-1.2.2\\n- cosProperty-1.2.2\\n- cosTime-1.2.2\\n- cosTransactions-1.3.2\\n- crypto-4.0\\n- debugger-4.2.2\\n- dialyzer-3.2\\n- diameter-2.0\\n- edoc-0.9\\n- eldap-1.2.2\\n- erl_docgen-0.7\\n- erl_interface-3.10\\n- et-1.6\\n- eunit-2.3.3\\n- hipe-3.16\\n- ic-4.4.2\\n- inets-6.4\\n- jinterface-1.8\\n- kernel-5.3\\n- megaco-3.18.2\\n- mnesia-4.15\\n- observer-2.4\\n- odbc-2.12\\n- orber-3.8.3\\n- os_mon-2.4.2\\n- otp_mibs-1.1.1\\n- parsetools-2.1.5\\n- public_key-1.4.1\\n- reltool-0.7.4\\n- sasl-3.0.4\\n- snmp-5.2.6\\n- ssh-4.5\\n- ssl-8.2\\n- syntax_tools-2.1.2\\n- wx-1.8.1\\n- xmerl-1.3.15\\n",
                      "tagger": {
                        "name": "Erlang/OTP",
                        "date": "2017-06-30T15:21:23+02:00"
                      }
                    }
                  }
                }
              ],
              "pageInfo": {
                "endCursor": "OTY=",
                "hasNextPage": true,
                "hasPreviousPage": false,
                "startCursor": "OTI="
              }
            },
            "releases": {
              "edges": [
                {
                  "cursor": "Y3Vyc29yOnYyOpHOAF//4w==",
                  "node": {
                    "id": "MDc6UmVsZWFzZTYyOTE0Mjc=",
                    "name": "OTP 20 RC1",
                    "description": "# OTP 20 Release Candidate 1\\r\\n\\r\\nThis is the first of two release candidates before the OTP 20 release. The intention with this release is that you as users try it and give us feedback if something does not work as expected. Could be a bug, an unexpected incompatibility, a significant change of characteristics in negative direction, etc.\\r\\n\\r\\nHere are some of the most important news:\\r\\n\\r\\n## Potential Incompatibilities\\r\\n\\r\\n- ERTS: \\r\\n    - The non SMP Erlang VM is deprecated and not built by default\\r\\n    - Remove deprecated `erlang:hash/2`\\r\\n    - erlang:statistics/1 with scheduler_wall_time now also includes info about dirty CPU schedulers.\\r\\n    - The new purge strategy introduced in OTP 19.1 is mandatory and slightly incompatible for processes holding funs\\r\\n      see `erlang:check_process_code/3`.\\r\\n    - The NIF library reload is not supported anymore.\\r\\n\\r\\n- Asn1: Deprecated module and functions removed (`asn1rt`, `asn1ct:encode/3` and `decode/3`)\\r\\n- Ssh: client only option in a call to start a daemon will now fail \\r\\n\\r\\n## Highlights\\r\\n\\r\\n### Erts:\\r\\n- Dirty schedulers enabled and supported on VM with SMP support.\\r\\n- support for “dirty” BIFs and “dirty” GC.\\r\\n- erlang:garbage_collect/2 for control of minor or major GC\\r\\n- Erlang literals are no longer copied when sending messages.\\r\\n- Improved performance for large ETS tables, >256 entries (except ordered_set)\\r\\n- erlang:system_info/1 atom_count and atom_limit\\r\\n- Reduced memory pressure by converting sub-binaries to heap-binaries during GC\\r\\n- enif_select, map an external event to message\\r\\n### Compiler:\\r\\n- Code generation for complicated guards is improved.\\r\\n- Warnings for repeated identical map keys. `\#{'a'=>1, 'b'=>2, 'a'=>3}` will warn for the repeated key `a`.\\r\\n- By default there is now a warning when `export_all` is used. Can be disabled\\r\\n- Pattern matching for maps is optimized\\r\\n- New option `deterministic` to omit path to source + options info the BEAM file.\\r\\n- Atoms may now contain arbitrary unicode characters.\\r\\n- `compile:file/2` has an option to include extra chunks in the BEAM file.\\r\\n\\r\\n### Misc other applications\\r\\n- Unnamed ets tables optimized\\r\\n- A new event manager to handle a subset of OS signals in Erlang \\r\\n- Optimized sets add_element, del_element and union\\r\\n- Added `rand:jump/0-1`\\r\\n- When a `gen_server` crashes, the stacktrace for the client will be printed to facilitate debugging.\\r\\n- `take/2` has been added to `dict`, `orddict`, and `gb_trees`.\\r\\n- `take_any/2` has been added to `gb_trees`\\r\\n- Significantly updated string module with unicode support\\r\\n- `erl_tar` support for long path names and new file formats\\r\\n- Dtls: Documented API, experimental\\r\\n- SSH: improving security, removing and adding algorithms\\r\\n- New  `math:fmod/2`\\r\\n\\r\\nFor more details see\\r\\nhttp://erlang.org/download/otp_src_20.0-rc1.readme\\r\\n\\r\\nPer built versions for Windows can be fetched here:\\r\\nhttp://erlang.org/download/otp_win32_20.0-rc1.exe\\r\\nhttp://erlang.org/download/otp_win64_20.0-rc1.exe\\r\\n\\r\\nOn line documentation can be browsed here:\\r\\n  www.erlang.org/documentation/doc-9.0-rc1/doc/\\r\\n\\r\\nThanks to all contributors.",
                    "publishedAt": "2017-05-31T15:43:09Z",
                    "isDraft": false,
                    "isPrerelease": true,
                    "tag": {
                      "id": "MDM6UmVmMzc0OTI3Ok9UUC0yMC4wLXJjMQ==",
                      "name": "OTP-20.0-rc1"
                    }
                  }
                },
                {
                  "cursor": "Y3Vyc29yOnYyOpHOAGQZwA==",
                  "node": {
                    "id": "MDc6UmVsZWFzZTY1NjAxOTI=",
                    "name": "OTP 20 RC2",
                    "description": "# OTP 20 Release Candidate 2\\r\\n\\r\\nThis is the second of two release candidates before the OTP 20 release. The intention with this release is that you as users try it and give us feedback if something does not work as expected. Could be a bug, an unexpected incompatibility, a significant change of characteristics in negative direction, etc.\\r\\n\\r\\nThere are only minor changes compared to the first release candidate, some of them listed below:\\r\\n-  erts: `./configure --enable-lock-counter` will enable building of an additional emulator that has support for\\r\\n               lock counting. (The option previously existed, but would turn on lock counting in the default emulator\\r\\n               being built.) To start the lock-counting emulator, use `erl -emu_type lcnt`.\\r\\n- kernel: Added the process_flag `message_queue_data` = `off_heap` to the `code_server` process in order to\\r\\n              improve characteristics during code upgrade, which can generate a huge amount of messages.\\r\\n\\r\\n\\r\\nHere are some of the most important news in OTP 20 (same as in RC1):\\r\\n\\r\\n## Potential Incompatibilities\\r\\n\\r\\n- ERTS: \\r\\n    - The non SMP Erlang VM is deprecated and not built by default\\r\\n    - Remove deprecated `erlang:hash/2`\\r\\n    - erlang:statistics/1 with scheduler_wall_time now also includes info about dirty CPU schedulers.\\r\\n    - The new purge strategy introduced in OTP 19.1 is mandatory and slightly incompatible for processes holding funs\\r\\n      see `erlang:check_process_code/3`.\\r\\n    - The NIF library reload is not supported anymore.\\r\\n\\r\\n- Asn1: Deprecated module and functions removed (`asn1rt`, `asn1ct:encode/3` and `decode/3`)\\r\\n- Ssh: client only option in a call to start a daemon will now fail \\r\\n\\r\\n## Highlights\\r\\n\\r\\n### Erts:\\r\\n- Dirty schedulers enabled and supported on VM with SMP support.\\r\\n- support for “dirty” BIFs and “dirty” GC.\\r\\n- erlang:garbage_collect/2 for control of minor or major GC\\r\\n- Erlang literals are no longer copied when sending messages.\\r\\n- Improved performance for large ETS tables, >256 entries (except ordered_set)\\r\\n- erlang:system_info/1 atom_count and atom_limit\\r\\n- Reduced memory pressure by converting sub-binaries to heap-binaries during GC\\r\\n- enif_select, map an external event to message\\r\\n### Compiler:\\r\\n- Code generation for complicated guards is improved.\\r\\n- Warnings for repeated identical map keys. `\#{'a'=>1, 'b'=>2, 'a'=>3}` will warn for the repeated key `a`.\\r\\n- By default there is now a warning when `export_all` is used. Can be disabled\\r\\n- Pattern matching for maps is optimized\\r\\n- New option `deterministic` to omit path to source + options info the BEAM file.\\r\\n- Atoms may now contain arbitrary unicode characters.\\r\\n- `compile:file/2` has an option to include extra chunks in the BEAM file.\\r\\n\\r\\n### Misc other applications\\r\\n- Unnamed ets tables optimized\\r\\n- A new event manager to handle a subset of OS signals in Erlang \\r\\n- Optimized sets add_element, del_element and union\\r\\n- Added `rand:jump/0-1`\\r\\n- When a `gen_server` crashes, the stacktrace for the client will be printed to facilitate debugging.\\r\\n- `take/2` has been added to `dict`, `orddict`, and `gb_trees`.\\r\\n- `take_any/2` has been added to `gb_trees`\\r\\n- Significantly updated string module with unicode support\\r\\n- `erl_tar` support for long path names and new file formats\\r\\n- Dtls: Documented API, experimental\\r\\n- SSH: improving security, removing and adding algorithms\\r\\n- New  `math:fmod/2`\\r\\n\\r\\nFor more details see\\r\\nhttp://erlang.org/download/otp_src_20.0-rc2.readme\\r\\n\\r\\nPer built versions for Windows can be fetched here:\\r\\nhttp://erlang.org/download/otp_win32_20.0-rc2.exe\\r\\nhttp://erlang.org/download/otp_win64_20.0-rc2.exe\\r\\n\\r\\nOn line documentation can be browsed here:\\r\\n  www.erlang.org/documentation/doc-9.0-rc2/doc/\\r\\n\\r\\nThanks to all contributors.",
                    "publishedAt": "2017-05-31T16:12:17Z",
                    "isDraft": false,
                    "isPrerelease": true,
                    "tag": {
                      "id": "MDM6UmVmMzc0OTI3Ok9UUC0yMC4wLXJjMg==",
                      "name": "OTP-20.0-rc2"
                    }
                  }
                },
                {
                  "cursor": "Y3Vyc29yOnYyOpHOAGd7TQ==",
                  "node": {
                    "id": "MDc6UmVsZWFzZTY3ODE3NzM=",
                    "name": "Erlang/OTP 20.0",
                    "description": "# Erlang/OTP 20.0\\r\\n\\r\\nErlang/OTP 20.0 is a new major release with new features, quite a few (characteristics) improvements, as well as a few incompatibilities.\\r\\n\\r\\nThere are only minor changes compared to the second release candidate, some of them listed below:\\r\\n- ERTS:\\r\\n    - In the OTP 20 release candidates the function `erlang:term_to_binary/1` changed the encoding of all atoms from `ATOM_EXT` to `ATOM_UTF8_EXT` and `SMALL_ATOM_UTF8_EXT`. This is now changed so that only atoms actually containing unicode characters are encoded with the UTF8 tags while other atoms are encoded `ATOM_EXT` just as before. \\r\\n\\r\\nHere are some of the most important news in OTP 20:\\r\\n\\r\\n## Potential Incompatibilities\\r\\n\\r\\n- ERTS: \\r\\n    - The non SMP Erlang VM is deprecated and not built by default\\r\\n    - Remove deprecated `erlang:hash/2`\\r\\n    - erlang:statistics/1 with scheduler_wall_time now also includes info about dirty CPU schedulers.\\r\\n    - The new purge strategy introduced in OTP 19.1 is mandatory and slightly incompatible for processes holding funs\\r\\n      see `erlang:check_process_code/3`.\\r\\n    - The NIF library reload is not supported anymore.\\r\\n    - Atoms can now contain arbitrary unicode characters which means that the `DFLAG_UTF8_ATOMS` capability in the distribution protocol must be supported if an OTP 20 node should accept the connection with another node or library. Third party libraries which uses the distribution protocol need to be updated with this. \\r\\n\\r\\n- Asn1: Deprecated module and functions removed (`asn1rt`, `asn1ct:encode/3` and `decode/3`)\\r\\n- Ssh: client only option in a call to start a daemon will now fail \\r\\n\\r\\n## Highlights\\r\\n\\r\\n### Erts:\\r\\n- Dirty schedulers enabled and supported on VM with SMP support.\\r\\n- support for “dirty” BIFs and “dirty” GC.\\r\\n- erlang:garbage_collect/2 for control of minor or major GC\\r\\n- Erlang literals are no longer copied when sending messages.\\r\\n- Improved performance for large ETS tables, >256 entries (except ordered_set)\\r\\n- erlang:system_info/1 atom_count and atom_limit\\r\\n- Reduced memory pressure by converting sub-binaries to heap-binaries during GC\\r\\n- enif_select, map an external event to message\\r\\n- Improvements of timers internally in the VM resulting in reduced memory consumption and more efficient administration for timers \\r\\n### Compiler:\\r\\n- Code generation for complicated guards is improved.\\r\\n- Warnings for repeated identical map keys. `\#{'a'=>1, 'b'=>2, 'a'=>3}` will warn for the repeated key `a`.\\r\\n- By default there is now a warning when `export_all` is used. Can be disabled\\r\\n- Pattern matching for maps is optimized\\r\\n- New option `deterministic` to omit path to source + options info the BEAM file.\\r\\n- Atoms may now contain arbitrary unicode characters.\\r\\n- `compile:file/2` has an option to include extra chunks in the BEAM file.\\r\\n\\r\\n### Misc other applications\\r\\n- Significantly updated `string` module with unicode support and many new functions\\r\\n- crypto now supports OpenSSL 1.1\\r\\n- Unnamed ets tables optimized\\r\\n- `gen_fsm` is deprecated and replaced by `gen_statem`\\r\\n- A new event manager to handle a subset of OS signals in Erlang \\r\\n- Optimized sets add_element, del_element and union\\r\\n- Added `rand:jump/0-1`\\r\\n- When a `gen_server` crashes, the stacktrace for the client will be printed to facilitate debugging.\\r\\n- `take/2` has been added to `dict`, `orddict`, and `gb_trees`.\\r\\n- `take_any/2` has been added to `gb_trees`\\r\\n- `erl_tar` support for long path names and new file formats\\r\\n- `asn1`: the new `maps` option changes the representation of `SEQUENCE` to be maps instead of records \\r\\n- A TLS client will by default call `public_key:pkix_verify_hostname/2` to verify the hostname\\r\\n- `ssl`: DTLS documented in the API, experimental\\r\\n- `ssh`: improving security, removing and adding algorithms\\r\\n- New  `math:fmod/2`\\r\\n\\r\\nFor more details see\\r\\nhttp://erlang.org/download/otp_src_20.0.readme\\r\\n\\r\\nPre built versions for Windows can be fetched here:\\r\\nhttp://erlang.org/download/otp_win32_20.0.exe\\r\\nhttp://erlang.org/download/otp_win64_20.0.exe\\r\\n\\r\\nOn line documentation can be browsed here:\\r\\n  www.erlang.org/doc/\\r\\n\\r\\nThanks to all contributors.",
                    "publishedAt": "2017-06-21T12:21:02Z",
                    "isDraft": false,
                    "isPrerelease": false,
                    "tag": {
                      "id": "MDM6UmVmMzc0OTI3Ok9UUC0yMC4w",
                      "name": "OTP-20.0"
                    }
                  }
                }
              ],
              "pageInfo": {
                "endCursor": "Y3Vyc29yOnYyOpHOAGd7TQ==",
                "hasNextPage": false,
                "hasPreviousPage": true,
                "startCursor": "Y3Vyc29yOnYyOpHOAF//4w=="
              }
            }
          }
        }
      }
      """
    end

    def new_releases_json(2) do
      """
      {
        "data": {
          "rateLimit": {
            "cost": 1,
            "limit": 5000,
            "nodeCount": 10,
            "remaining": 4992,
            "resetAt": "2017-08-28T07:27:53Z"
          },
          "repository": {
            "tags": {
              "edges": [
                {
                  "cursor": "OTc=",
                  "node": {
                    "id": "MDM6UmVmMzc0OTI3Ok9UUC0yMC4wLjI=",
                    "name": "OTP-20.0.2",
                    "target": {
                      "id": "MDM6VGFnMzc0OTI3OmVmMTgyYzI2MGY2M2JlMGU5Mjg1N2Q1N2RhNDRmMGQxMzIyNDQyNmE=",
                      "message": "=== OTP-20.0.2 ===\\n\\nChanged Applications:\\n- asn1-5.0.1\\n- erts-9.0.2\\n- kernel-5.3.1\\n\\nUnchanged Applications:\\n- common_test-1.15.1\\n- compiler-7.1\\n- cosEvent-2.2.1\\n- cosEventDomain-1.2.1\\n- cosFileTransfer-1.2.1\\n- cosNotification-1.2.2\\n- cosProperty-1.2.2\\n- cosTime-1.2.2\\n- cosTransactions-1.3.2\\n- crypto-4.0\\n- debugger-4.2.2\\n- dialyzer-3.2\\n- diameter-2.0\\n- edoc-0.9\\n- eldap-1.2.2\\n- erl_docgen-0.7\\n- erl_interface-3.10\\n- et-1.6\\n- eunit-2.3.3\\n- hipe-3.16\\n- ic-4.4.2\\n- inets-6.4\\n- jinterface-1.8\\n- megaco-3.18.2\\n- mnesia-4.15\\n- observer-2.4\\n- odbc-2.12\\n- orber-3.8.3\\n- os_mon-2.4.2\\n- otp_mibs-1.1.1\\n- parsetools-2.1.5\\n- public_key-1.4.1\\n- reltool-0.7.4\\n- runtime_tools-1.12.1\\n- sasl-3.0.4\\n- snmp-5.2.6\\n- ssh-4.5\\n- ssl-8.2\\n- stdlib-3.4.1\\n- syntax_tools-2.1.2\\n- tools-2.10.1\\n- wx-1.8.1\\n- xmerl-1.3.15\\n",
                      "tagger": {
                        "name": "Erlang/OTP",
                        "date": "2017-07-26T11:46:41+02:00"
                      }
                    }
                  }
                },
                {
                  "cursor": "OTg=",
                  "node": {
                    "id": "MDM6UmVmMzc0OTI3Ok9UUC0yMC4wLjM=",
                    "name": "OTP-20.0.3",
                    "target": {
                      "id": "MDM6VGFnMzc0OTI3OjQxZTNmMDQ2ZjJkZDU1NWNlZTUyZmMzZjJhNWI3ODI4YmM0MzU4ZGQ=",
                      "message": "=== OTP-20.0.3 ===\\n\\nChanged Applications:\\n- asn1-5.0.2\\n- compiler-7.1.1\\n- erts-9.0.3\\n- ssh-4.5.1\\n\\nUnchanged Applications:\\n- common_test-1.15.1\\n- cosEvent-2.2.1\\n- cosEventDomain-1.2.1\\n- cosFileTransfer-1.2.1\\n- cosNotification-1.2.2\\n- cosProperty-1.2.2\\n- cosTime-1.2.2\\n- cosTransactions-1.3.2\\n- crypto-4.0\\n- debugger-4.2.2\\n- dialyzer-3.2\\n- diameter-2.0\\n- edoc-0.9\\n- eldap-1.2.2\\n- erl_docgen-0.7\\n- erl_interface-3.10\\n- et-1.6\\n- eunit-2.3.3\\n- hipe-3.16\\n- ic-4.4.2\\n- inets-6.4\\n- jinterface-1.8\\n- kernel-5.3.1\\n- megaco-3.18.2\\n- mnesia-4.15\\n- observer-2.4\\n- odbc-2.12\\n- orber-3.8.3\\n- os_mon-2.4.2\\n- otp_mibs-1.1.1\\n- parsetools-2.1.5\\n- public_key-1.4.1\\n- reltool-0.7.4\\n- runtime_tools-1.12.1\\n- sasl-3.0.4\\n- snmp-5.2.6\\n- ssl-8.2\\n- stdlib-3.4.1\\n- syntax_tools-2.1.2\\n- tools-2.10.1\\n- wx-1.8.1\\n- xmerl-1.3.15\\n",
                      "tagger": {
                        "name": "Erlang/OTP",
                        "date": "2017-08-23T10:39:52+02:00"
                      }
                    }
                  }
                },
                {
                  "cursor": "OTk=",
                  "node": {
                    "id": "MDM6UmVmMzc0OTI3Ok9UUC0yMC4wLjQ=",
                    "name": "OTP-20.0.4",
                    "target": {
                      "id": "MDM6VGFnMzc0OTI3OjY0OWFiYTFlOTQ5ZmYxYTQ2ZmY5NzM0ZDdmOWEzNTBhNTljMjNjNWY=",
                      "message": "=== OTP-20.0.4 ===\\n\\nChanged Applications:\\n- dialyzer-3.2.1\\n- erts-9.0.4\\n\\nUnchanged Applications:\\n- asn1-5.0.2\\n- common_test-1.15.1\\n- compiler-7.1.1\\n- cosEvent-2.2.1\\n- cosEventDomain-1.2.1\\n- cosFileTransfer-1.2.1\\n- cosNotification-1.2.2\\n- cosProperty-1.2.2\\n- cosTime-1.2.2\\n- cosTransactions-1.3.2\\n- crypto-4.0\\n- debugger-4.2.2\\n- diameter-2.0\\n- edoc-0.9\\n- eldap-1.2.2\\n- erl_docgen-0.7\\n- erl_interface-3.10\\n- et-1.6\\n- eunit-2.3.3\\n- hipe-3.16\\n- ic-4.4.2\\n- inets-6.4\\n- jinterface-1.8\\n- kernel-5.3.1\\n- megaco-3.18.2\\n- mnesia-4.15\\n- observer-2.4\\n- odbc-2.12\\n- orber-3.8.3\\n- os_mon-2.4.2\\n- otp_mibs-1.1.1\\n- parsetools-2.1.5\\n- public_key-1.4.1\\n- reltool-0.7.4\\n- runtime_tools-1.12.1\\n- sasl-3.0.4\\n- snmp-5.2.6\\n- ssh-4.5.1\\n- ssl-8.2\\n- stdlib-3.4.1\\n- syntax_tools-2.1.2\\n- tools-2.10.1\\n- wx-1.8.1\\n- xmerl-1.3.15\\n",
                      "tagger": {
                        "name": "Erlang/OTP",
                        "date": "2017-08-25T09:36:12+02:00"
                      }
                    }
                  }
                },
                {
                  "cursor": "MTAw",
                  "node": {
                    "id": "MDM6UmVmMzc0OTI3Ok9UUF9SMTNCMDM=",
                    "name": "OTP_R13B03",
                    "target": {
                      "id": "MDM6VGFnMzc0OTI3OjBlMzQ4ZWNlMDFmM2Q2NzU0NjQ0YWEyYjc4ZjA2NzEwNWQ5MGVjZjM=",
                      "message": "The R13B03 release.\\n",
                      "tagger": {
                        "name": "Erlang/OTP",
                        "date": "2009-11-20T15:54:40+01:00"
                      }
                    }
                  }
                },
                {
                  "cursor": "MTAx",
                  "node": {
                    "id": "MDM6UmVmMzc0OTI3Ok9UUF9SMTNCMDQ=",
                    "name": "OTP_R13B04",
                    "target": {
                      "id": "MDM6VGFnMzc0OTI3OjNlYmI4N2NjOWNiOWNmNDA1ZmIxMGIzMzkyM2U5ZDFhMGU5MWY0YzE=",
                      "message": "The R13B04 release\\n",
                      "tagger": {
                        "name": "Erlang/OTP",
                        "date": "2010-02-19T19:11:35+01:00"
                      }
                    }
                  }
                }
              ],
              "pageInfo": {
                "endCursor": "MTAx",
                "hasNextPage": false,
                "hasPreviousPage": true,
                "startCursor": "OTc="
              }
            },
            "releases": {
              "edges": [],
              "pageInfo": {
                "endCursor": null,
                "hasNextPage": false,
                "hasPreviousPage": true,
                "startCursor": null
              }
            }
          }
        }
      }
      """
    end

    def no_new_releases_json do
      """
      {
        "data": {
          "rateLimit": {
            "cost": 1,
            "limit": 5000,
            "nodeCount": 105,
            "remaining": 4996,
            "resetAt": "2017-09-02T10:42:31Z"
          },
          "repository": {
            "tags": {
              "edges": [],
              "pageInfo": {
                "endCursor": null,
                "hasNextPage": false,
                "hasPreviousPage": false,
                "startCursor": null
              }
            },
            "releases": {
              "edges": [],
              "pageInfo": {
                "endCursor": null,
                "hasNextPage": false,
                "hasPreviousPage": true,
                "startCursor": null
              }
            }
          }
        }
      }
      """
    end

    def rate_limit_headers(conn) do
      conn
        |> Plug.Conn.put_resp_header("access-control-allow-origin", "*")
        |> Plug.Conn.put_resp_header("access-control-expose-headers", "ETag, Link, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval")
        |> Plug.Conn.put_resp_header("cache-control", "no-cache")
        |> Plug.Conn.put_resp_header("content-encoding", "gzip")
        |> Plug.Conn.put_resp_header("content-type", "application/json; charset=utf-8")
        |> Plug.Conn.put_resp_header("content-security-policy", "default-src 'none'")
        |> Plug.Conn.put_resp_header("date", "Mon, 28 Aug 2017 22:44:52 GMT")
        |> Plug.Conn.put_resp_header("server", "GitHub.com")
        |> Plug.Conn.put_resp_header("status", "200 OK")
        |> Plug.Conn.put_resp_header("strict-transport-security", "max-age=31536000; includeSubdomains; preload")
        |> Plug.Conn.put_resp_header("x-accepted-oauth-scopes", "repo")
        |> Plug.Conn.put_resp_header("x-content-type-options", "nosniff")
        |> Plug.Conn.put_resp_header("x-frame-options", "deny")
        |> Plug.Conn.put_resp_header("x-github-media-type", "github.v4; format=json")
        |> Plug.Conn.put_resp_header("x-github-request-id", "CBBB:206F:3DAF8EB:86C9223:59A49CE4")
        |> Plug.Conn.put_resp_header("x-oauth-scopes", "")
        |> Plug.Conn.put_resp_header("x-ratelimit-limit", "5000")
        |> Plug.Conn.put_resp_header("x-ratelimit-remaining", "5000")
        |> Plug.Conn.put_resp_header("x-ratelimit-reset", "1503960268")
        |> Plug.Conn.put_resp_header("x-runtime-rack", "0.015669")
        |> Plug.Conn.put_resp_header("x-xss-protection", "1; mode=block")
    end

    def new_releases_connection_with_headers(conn, 1) do
      conn
        |> Plug.Conn.put_resp_header("access-control-allow-origin", "*")
        |> Plug.Conn.put_resp_header("access-control-expose-headers", "ETag, Link, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval")
        |> Plug.Conn.put_resp_header("cache-control", "no-cache")
        |> Plug.Conn.put_resp_header("content-encoding", "gzip")
        |> Plug.Conn.put_resp_header("content-type", "application/json; charset=utf-8")
        |> Plug.Conn.put_resp_header("content-security-policy", "default-src 'none'")
        |> Plug.Conn.put_resp_header("date", "Mon, 28 Aug 2017 06:40:58 GMT")
        |> Plug.Conn.put_resp_header("server", "GitHub.com")
        |> Plug.Conn.put_resp_header("status", "200 OK")
        |> Plug.Conn.put_resp_header("strict-transport-security", "max-age=31536000; includeSubdomains; preload")
        |> Plug.Conn.put_resp_header("x-accepted-oauth-scopes", "repo")
        |> Plug.Conn.put_resp_header("x-content-type-options", "nosniff")
        |> Plug.Conn.put_resp_header("x-frame-options", "deny")
        |> Plug.Conn.put_resp_header("x-github-media-type", "github.v4; format=json")
        |> Plug.Conn.put_resp_header("x-github-request-id", "C35A:2071:642FCB9:CAED084:59A3BAFA")
        |> Plug.Conn.put_resp_header("x-oauth-scopes", "")
        |> Plug.Conn.put_resp_header("x-ratelimit-limit", "5000")
        |> Plug.Conn.put_resp_header("x-ratelimit-remaining", "4993")
        |> Plug.Conn.put_resp_header("x-ratelimit-reset", "1503905273")
        |> Plug.Conn.put_resp_header("x-runtime-rack", "0.053413")
        |> Plug.Conn.put_resp_header("x-xss-protection", "1; mode=block")
    end

    def new_releases_connection_with_headers(conn, 2) do
      conn
        |> Plug.Conn.put_resp_header("access-control-allow-origin", "*")
        |> Plug.Conn.put_resp_header("access-control-expose-headers", "ETag, Link, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval")
        |> Plug.Conn.put_resp_header("cache-control", "no-cache")
        |> Plug.Conn.put_resp_header("content-encoding", "gzip")
        |> Plug.Conn.put_resp_header("content-type", "application/json; charset=utf-8")
        |> Plug.Conn.put_resp_header("content-security-policy", "default-src 'none'")
        |> Plug.Conn.put_resp_header("date", "Mon, 28 Aug 2017 06:40:58 GMT")
        |> Plug.Conn.put_resp_header("server", "GitHub.com")
        |> Plug.Conn.put_resp_header("status", "200 OK")
        |> Plug.Conn.put_resp_header("strict-transport-security", "max-age=31536000; includeSubdomains; preload")
        |> Plug.Conn.put_resp_header("x-accepted-oauth-scopes", "repo")
        |> Plug.Conn.put_resp_header("x-content-type-options", "nosniff")
        |> Plug.Conn.put_resp_header("x-frame-options", "deny")
        |> Plug.Conn.put_resp_header("x-github-media-type", "github.v4; format=json")
        |> Plug.Conn.put_resp_header("x-github-request-id", "DE90:2070:4B14F0C:9E475BE:59A3C08E")
        |> Plug.Conn.put_resp_header("x-oauth-scopes", "")
        |> Plug.Conn.put_resp_header("x-ratelimit-limit", "5000")
        |> Plug.Conn.put_resp_header("x-ratelimit-remaining", "4992")
        |> Plug.Conn.put_resp_header("x-ratelimit-reset", "1503905273")
        |> Plug.Conn.put_resp_header("x-runtime-rack", "0.055600")
        |> Plug.Conn.put_resp_header("x-xss-protection", "1; mode=block")
    end

    def no_new_releases_connection_with_headers(conn) do
      conn
        |> Plug.Conn.put_resp_header("access-control-allow-origin", "*")
        |> Plug.Conn.put_resp_header("access-control-expose-headers", "ETag, Link, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval")
        |> Plug.Conn.put_resp_header("cache-control", "no-cache")
        |> Plug.Conn.put_resp_header("content-encoding", "gzip")
        |> Plug.Conn.put_resp_header("content-type", "application/json; charset=utf-8")
        |> Plug.Conn.put_resp_header("content-security-policy", "default-src 'none'")
        |> Plug.Conn.put_resp_header("date", "Mon, 28 Aug 2017 21:06:59 GMT")
        |> Plug.Conn.put_resp_header("server", "GitHub.com")
        |> Plug.Conn.put_resp_header("status", "200 OK")
        |> Plug.Conn.put_resp_header("strict-transport-security", "max-age=31536000; includeSubdomains; preload")
        |> Plug.Conn.put_resp_header("x-accepted-oauth-scopes", "repo")
        |> Plug.Conn.put_resp_header("x-content-type-options", "nosniff")
        |> Plug.Conn.put_resp_header("x-frame-options", "deny")
        |> Plug.Conn.put_resp_header("x-github-media-type", "github.v4; format=json")
        |> Plug.Conn.put_resp_header("x-github-request-id", "C16E:2071:6FF1EE4:E38B049:59A485F3")
        |> Plug.Conn.put_resp_header("x-oauth-scopes", "")
        |> Plug.Conn.put_resp_header("x-ratelimit-limit", "5000")
        |> Plug.Conn.put_resp_header("x-ratelimit-remaining", "4999")
        |> Plug.Conn.put_resp_header("x-ratelimit-reset", "1503958019")
        |> Plug.Conn.put_resp_header("x-runtime-rack", "0.048417")
        |> Plug.Conn.put_resp_header("x-xss-protection", "1; mode=block")
    end
  end
end
