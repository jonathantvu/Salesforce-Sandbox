global class DeleteDMDFilesScheduler implements Schedulable{
    
    global void execute(system.SchedulableContext sc){
        DeleteDMDFilesBatch batch = new DeleteDMDFilesBatch();
        database.executeBatch(batch);
    }
    
}