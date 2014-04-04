STATE["job"] = {
  enter = function(ctx)
    return enter_job_state()
  end,

  update = function(ctx)
    return update_job()
  end,

  leave = function(ctx)
    leave_job_state()
  end
}
