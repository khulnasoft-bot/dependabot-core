namespace NuGetUpdater.Core.Run.ApiModel;

public sealed record Job
{
    public required string PackageManager { get; init; }
    public AllowedUpdate[]? AllowedUpdates { get; init; } = null;
    public bool Debug { get; init; } = false;
    public object[]? DependencyGroups { get; init; } = null;
    public object[]? Dependencies { get; init; } = null;
    public string? DependencyGroupToRefresh { get; init; } = null;
    public object[]? ExistingPullRequests { get; init; } = null;
    public object[]? ExistingGroupPullRequests { get; init; } = null;
    public Dictionary<string, object>? Experiments { get; init; } = null;
    public object[]? IgnoreConditions { get; init; } = null;
    public bool LockfileOnly { get; init; } = false;
    public string? RequirementsUpdateStrategy { get; init; } = null;
    public object[]? SecurityAdvisories { get; init; } = null;
    public bool SecurityUpdatesOnly { get; init; } = false;
    public required JobSource Source { get; init; }
    public bool UpdateSubdependencies { get; init; } = false;
    public bool UpdatingAPullRequest { get; init; } = false;
    public bool VendorDependencies { get; init; } = false;
    public bool RejectExternalCode { get; init; } = false;
    public bool RepoPrivate { get; init; } = false;
    public object? CommitMessageOptions { get; init; } = null;
    public object[]? CredentialsMetadata { get; init; } = null;
    public int MaxUpdaterRunTime { get; init; } = 0;

    public IEnumerable<string> GetAllDirectories()
    {
        var returnedADirectory = false;
        if (Source.Directory is not null)
        {
            returnedADirectory = true;
            yield return Source.Directory;
        }

        foreach (var directory in Source.Directories ?? [])
        {
            returnedADirectory = true;
            yield return directory;
        }

        if (!returnedADirectory)
        {
            yield return "/";
        }
    }
}
