local path = ({...})[1]:gsub("%.init", "")
require(path .. ".carpenter")
require(path .. ".array")
