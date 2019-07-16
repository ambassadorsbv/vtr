def filterHiddenFiles(filepaths):
    return [
        path for path in filepaths
        if not path.startswith(".")
        and not path.startswith("_")
        and not path.startswith("._")
    ]
# end filterHiddenFiles
