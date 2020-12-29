setws ./L1S32.sdk

platform create -name L1S32_Top -hw ./L1S32_Top.xsa
platform write

set repo_path_1 [file normalize "./ip_repo"]
repo -set "$repo_path_1"

repo -scan

domain create -name {standalone_domain} -display-name {standalone on microblaze_0} -os {standalone} -proc [hsi::get_cells -filter { IP_TYPE == "PROCESSOR" } ] -support-app {empty_application}
platform write
platform generate
app create -name L1S32 -platform L1S32_Top -proc [hsi::get_cells -filter { IP_TYPE == "PROCESSOR" } ] -template {Empty Application (C++)} -domain standalone_domain -lang c++
importsources -name L1S32 -path [file normalize cpu/] -soft-link
app build -name L1S32

exit
