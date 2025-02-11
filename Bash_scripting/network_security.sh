#!/bin/bash

# Vérification des permissions root
if [ "$EUID" -ne 0 ]; then
  echo "Veuillez exécuter ce script avec les privilèges root."
  exit 1
fi

echo "-------------------------------------"
echo " Analyse de sécurité réseau avancée "
echo "-------------------------------------"

# Demande de l'adresse IP cible
read -p "Entrez l'adresse IP cible : " TARGET

# Vérification de la connectivité
echo "[+] Vérification de la connectivité avec $TARGET..."
ping -c 2 $TARGET > /dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "[-] Cible inaccessible. Vérifiez l'adresse IP."
  exit 1
else
  echo "[+] Cible accessible."
fi

# Dossier pour stocker les résultats
RESULTS_DIR="scan_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p $RESULTS_DIR

# Scan réseau avancé avec nmap
echo "[+] Lancement de l'analyse avec nmap..."
nmap -A -T4 -p- $TARGET -oN $RESULTS_DIR/nmap_results.txt

echo "[+] Analyse nmap terminée. Résultats enregistrés dans $RESULTS_DIR/nmap_results.txt"

# Surveillance du trafic réseau avec tcpdump
echo "[+] Capture du trafic réseau avec tcpdump. Appuyez sur Ctrl+C pour arrêter."
tcpdump -i eth0 -w $RESULTS_DIR/traffic_capture.pcap &
TCPDUMP_PID=$!

# Surveillance pendant une durée définie (30 secondes)
sleep 30

# Arrêter tcpdump
kill $TCPDUMP_PID
echo "[+] Capture du trafic terminée. Fichier enregistré : $RESULTS_DIR/traffic_capture.pcap"

# Analyse sommaire des résultats
echo "[+] Ports ouverts détectés :"
grep "open" $RESULTS_DIR/nmap_results.txt | awk '{print $1, $2}'

echo "-------------------------------------"
echo " Analyse terminée. Résultats disponibles dans $RESULTS_DIR/"
echo "-------------------------------------"

