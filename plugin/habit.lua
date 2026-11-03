vim.api.nvim_create_user_command("HabitInsert", fucntion()
  require("habit").insert)
end, { desc = "Inserts your habit tracker template below the cursor" })
