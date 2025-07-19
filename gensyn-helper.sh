#!/bin/bash

USER_HOME=$(eval echo ~$(whoami))
SWARM_PATH="$USER_HOME/rl-swarm/modal-login"
BACKUP_PATH="$USER_HOME/rl-swarm/backup"

mkdir -p "$BACKUP_PATH"

while true; do
  clear
  echo -e "\033[1;36m🌟 Gensyn Crash & Recovery Helper Menu:\033[0m"
  echo "1️⃣  Backup temp-data folder"
  echo "2️⃣  Start GEN watcher (auto respond + restore)"
  echo "3️⃣  Exit"
  echo -n "👉 Enter your choice [1-3]: "
  read choice

  case $choice in
    1)
      echo "📦 Creating backup of temp-data folder..."
      if [ -d "$SWARM_PATH/temp-data" ]; then
        rm -rf "$BACKUP_PATH/temp-data"
        cp -r "$SWARM_PATH/temp-data" "$BACKUP_PATH/temp-data"
        echo "✅ Backup saved at $BACKUP_PATH/temp-data"
      else
        echo "❌ temp-data folder not found in $SWARM_PATH"
      fi
      read -p "Press Enter to continue..."
      ;;

    2)
      echo "👀 Starting GEN session watcher..."
      tmux pipe-pane -t GEN -o "cat >> /tmp/genlog.txt"
      tail -Fn0 /tmp/genlog.txt | while read line; do

        if [[ "$line" == *"Do you want to login to huggingface"* ]]; then
          echo "🤖 Huggingface prompt detected! Sending 'n'..."
          tmux send-keys -t GEN "n" C-m
        fi

        if [[ "$line" == *"Please enter model name"* || "$line" == *"Model"* ]]; then
          echo "🤖 Model prompt detected! Sending model name..."
          tmux send-keys -t GEN "Gensyn/Qwen2.5-0.5B-Instruct" C-m
        fi

        if [[ "$line" == *"wait for logging"* || "$line" == *"failed to logging"* ]]; then
          if [[ -d "$BACKUP_PATH/temp-data" ]]; then
            echo "♻️ Restoring temp-data folder from backup..."
            rm -rf "$SWARM_PATH/temp-data"
            cp -r "$BACKUP_PATH/temp-data" "$SWARM_PATH/temp-data"
            echo "✅ temp-data folder restored!"
          else
            echo "⚠️ Backup temp-data folder not found!"
          fi
        fi

      done
      ;;

    3)
      echo "👋 Exiting... Goodbye!"
      exit 0
      ;;

    *)
      echo "❌ Invalid choice. Please choose 1-3."
      sleep 2
      ;;
  esac
done
