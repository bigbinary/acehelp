if Delayed::Worker.delay_jobs && !($PROGRAM_NAME =~ /(rake|delayed_job)(.rb)?$/)
  AutoCloseResolvedTicketsJob.schedule!
end
