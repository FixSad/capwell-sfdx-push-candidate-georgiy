trigger trg_Account on Account (after insert) {
    if (Trigger.isInsert && Trigger.isAfter) {
        accountTeamController.autoCreateTeams(Trigger.New);
    }
}