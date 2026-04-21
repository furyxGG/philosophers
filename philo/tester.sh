#!/bin/bash

# ============================================================
#  PHILO TESTER — 70+ edge case + öncelik sistemi
#  Kullanım: ./test_philo.sh [philo binary path]
#  Default: ./philo
#
#  Öncelik seviyeleri:
#    CRITICAL  — Mutlaka fix edilmeli (eval'da direkt fail)
#    MEDIUM    — Fixlenmeli ama program çalışıyor
#    LOW       — Küçük sorun, zorunlu değil
# ============================================================

PHILO="${1:-./philo}"
PASS=0
FAIL=0

CRITICAL_FAILS=()
MEDIUM_FAILS=()
LOW_FAILS=()

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
BOLD="\033[1m"
MAGENTA="\033[0;35m"
RESET="\033[0m"

priority_label() {
	case "$1" in
		CRITICAL) echo -e "${RED}${BOLD}[CRITICAL]${RESET}" ;;
		MEDIUM)   echo -e "${YELLOW}${BOLD}[MEDIUM]${RESET}" ;;
		LOW)      echo -e "${MAGENTA}[LOW]${RESET}" ;;
	esac
}

record_fail() {
	local priority="$1" desc="$2"
	case "$priority" in
		CRITICAL) CRITICAL_FAILS+=("$desc") ;;
		MEDIUM)   MEDIUM_FAILS+=("$desc") ;;
		LOW)      LOW_FAILS+=("$desc") ;;
	esac
	((FAIL++))
}

# ============================================================
# YARDIMCI FONKSİYONLAR
# İmza: <fonksiyon> <priority> <desc> <timeout_veya_args...>
# ============================================================

DIM="\033[2m"

# Komutu ekrana basar: ./philo 5 800 200 200
show_cmd() {
	echo -e "  ${DIM}→ $PHILO $*${RESET}"
}

run_timed() {
	local t=$1; shift
	timeout "$t" "$PHILO" "$@" 2>/dev/null
}

# Fail detayını göster: neden fail aldı, doğrusu ne olmalıydı
fail_detail() {
	local reason="$1" expected="$2" got="$3"
	echo -e "  ${RED}  Neden  :${RESET} $reason"
	echo -e "  ${GREEN}  Olmalı :${RESET} $expected"
	if [ -n "$got" ]; then
		echo -e "  ${RED}  Olan   :${RESET} $got"
	fi
}

expect_exit_nonzero() {
	local priority="$1" desc="$2"; shift 2
	show_cmd "$@"
	timeout 5 "$PHILO" "$@" > /dev/null 2>&1
	local code=$?
	# timeout (124) da non-zero sayılır — program durmaması da bir hata

	if [ "$code" -ne 0 ] && [ "$code" -ne 124 ]; then
		echo -e "${GREEN}[PASS]${RESET} $desc"
		((PASS++))
	elif [ "$code" -eq 124 ]; then
		echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
		fail_detail \
			"Program 5sn içinde çıkmadı — geçersiz argümanda takılı kaldı" \
			"Hatalı argüman verildiğinde program hemen hata mesajı verip çıkmalı" \
			"Timeout (program hâlâ çalışıyor)"
		record_fail "$priority" "$desc"
	else
		echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
		fail_detail \
			"Geçersiz argümanda program hata vermeden çalıştı" \
			"Exit code non-zero (hata mesajı + çıkış) olmalı" \
			"Exit code: $code (0 = başarılı çıkış)"
		record_fail "$priority" "$desc"
	fi
}

expect_clean_exit() {
	local priority="$1" desc="$2" t=$3; shift 3
	show_cmd "$@"
	run_timed "$t" "$@" > /dev/null 2>&1
	local code=$?
	if [ "$code" -eq 0 ]; then
		echo -e "${GREEN}[PASS]${RESET} $desc"
		((PASS++))
	else
		if [ "$code" -eq 124 ]; then
			echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
			fail_detail \
				"Program ${t}sn içinde bitmedi (timeout)" \
				"Tüm filozoflar yeterince yediğinde program kendiliğinden exit 0 ile çıkmalı" \
				"Timeout — program hâlâ çalışıyor"
		else
			echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
			fail_detail \
				"Program başarılı bitmedi" \
				"Exit code 0 ile temiz çıkış bekleniyor" \
				"Exit code: $code"
		fi
		record_fail "$priority" "$desc"
	fi
}

expect_no_exit() {
	local priority="$1" desc="$2" t=$3; shift 3
	show_cmd "$@"
	run_timed "$t" "$@" > /dev/null 2>&1
	local code=$?
	if [ "$code" -eq 124 ]; then
		echo -e "${GREEN}[PASS]${RESET} $desc"
		((PASS++))
	else
		echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
		fail_detail \
			"Program ${t}sn içinde beklenmedik şekilde sonlandı" \
			"Filozoflar sonsuz döngüde yaşamaya devam etmeli, program durmamalı" \
			"Exit code: $code"
		record_fail "$priority" "$desc"
	fi
}

expect_no_death() {
	local priority="$1" desc="$2" t=$3; shift 3
	show_cmd "$@"
	local out
	out=$(run_timed "$t" "$@" 2>/dev/null)
	if echo "$out" | grep -q "died"; then
		local death_log
		death_log=$(echo "$out" | grep "died" | head -1)
		echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
		fail_detail \
			"Bu argümanlarla hiçbir filozof ölmemeli — yeterli zaman var" \
			"Tüm filozoflar yaşamaya devam etmeli (çıktıda 'died' olmamalı)" \
			"$death_log"
		record_fail "$priority" "$desc"
	else
		echo -e "${GREEN}[PASS]${RESET} $desc"
		((PASS++))
	fi
}

expect_death() {
	local priority="$1" desc="$2" t=$3; shift 3
	show_cmd "$@"
	local out
	out=$(run_timed "$t" "$@" 2>/dev/null)
	if echo "$out" | grep -q "died"; then
		echo -e "${GREEN}[PASS]${RESET} $desc"
		((PASS++))
	else
		echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
		fail_detail \
			"Bu argümanlarla en az bir filozofun ölmesi gerekiyor" \
			"Çıktıda 'X died' satırı görünmeli" \
			"Hiçbir 'died' logu yok — deadlock veya yanlış timing olabilir"
		record_fail "$priority" "$desc"
	fi
}

expect_no_log_after_death() {
	local priority="$1" desc="$2" t=$3; shift 3
	show_cmd "$@"
	local out
	out=$(run_timed "$t" "$@" 2>/dev/null)
	local death_line total
	death_line=$(echo "$out" | grep -n "died" | head -1 | cut -d: -f1)
	if [ -z "$death_line" ]; then
		echo -e "${YELLOW}[SKIP]${RESET} $desc (ölüm olmadı, kontrol atlandı)"
		return
	fi
	total=$(echo "$out" | wc -l)
	local extra=$(( total - death_line ))
	if [ "$total" -le $((death_line + 1)) ]; then
		echo -e "${GREEN}[PASS]${RESET} $desc"
		((PASS++))
	else
		local extra_lines
		extra_lines=$(echo "$out" | tail -n "$extra" | head -3)
		echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
		fail_detail \
			"Ölüm loglandıktan sonra $extra satır daha yazıldı" \
			"'died' basıldıktan sonra başka hiçbir log satırı çıkmamalı" \
			"$(echo "$extra_lines" | head -1) ..."
		record_fail "$priority" "$desc"
	fi
}

check_output_format() {
	local priority="$1" desc="$2" t=$3; shift 3
	show_cmd "$@"
	local out bad
	out=$(run_timed "$t" "$@" 2>/dev/null)
	bad=$(echo "$out" | grep -vE '^[0-9]+ [0-9]+ (is eating|is sleeping|is thinking|has taken a fork|died)$')
	if [ -z "$bad" ]; then
		echo -e "${GREEN}[PASS]${RESET} $desc"
		((PASS++))
	else
		echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
		fail_detail \
			"Çıktıda beklenen formata uymayan satır(lar) var" \
			"Her satır: 'timestamp_ms filozofID durum' formatında olmalı" \
			"Hatalı satır: $(echo "$bad" | head -1)"
		record_fail "$priority" "$desc"
	fi
}

check_valgrind() {
	local priority="$1" desc="$2" t=$3; shift 3
	show_cmd "$@"
	if ! command -v valgrind &>/dev/null; then
		echo -e "${YELLOW}[SKIP]${RESET} $desc (valgrind kurulu değil)"
		return
	fi
	timeout "$t" valgrind \
		--leak-check=full \
		--show-leak-kinds=all \
		--track-origins=yes \
		--error-exitcode=42 \
		--log-file=/tmp/vg_philo.log \
		"$PHILO" "$@" > /dev/null 2>&1

	# Leak kontrolü: "definitely lost: 0 bytes" veya hiç heap kullanımı yoksa OK
	local lost_line error_line lost_bytes error_count
	lost_line=$(grep "definitely lost:" /tmp/vg_philo.log | tail -1)
	error_line=$(grep "ERROR SUMMARY:" /tmp/vg_philo.log | tail -1)
	lost_bytes=$(echo "$lost_line" | grep -oE '[0-9,]+ bytes' | head -1 | tr -d ',')
	error_count=$(echo "$error_line" | grep -oE '[0-9]+ errors' | head -1 | grep -oE '[0-9]+')

	# "definitely lost: 0 bytes" VE "ERROR SUMMARY: 0 errors" olmalı
	local ok=1
	[ "${lost_bytes:-1}" != "0 bytes" ] && [ -n "$lost_line" ] && ok=0
	[ "${error_count:-1}" != "0" ] && [ -n "$error_line" ] && ok=0

	if [ "$ok" -eq 1 ]; then
		echo -e "${GREEN}[PASS]${RESET} $desc"
		((PASS++))
	else
		echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
		local leak_detail=""
		[ -n "$lost_line" ] && leak_detail="$lost_line"
		[ -n "$error_line" ] && leak_detail="$leak_detail | $error_line"
		fail_detail \
			"Valgrind memory leak veya hata tespit etti" \
			"definitely lost: 0 bytes | ERROR SUMMARY: 0 errors olmalı" \
			"$(echo "$leak_detail" | sed 's/==[0-9]*== //g' | xargs)"
		# Ek detay: indirectly lost ve suppressions
		grep -E "definitely lost|indirectly lost|possibly lost|ERROR SUMMARY" \
			/tmp/vg_philo.log | sed 's/==[0-9]*==\s*/    /g' | grep -v "^    $"
		record_fail "$priority" "$desc"
	fi
}

check_death_timing() {
	local priority="$1" desc="$2" t=$3 ttd=$4; shift 4
	show_cmd "$@"
	local out death_ts
	out=$(run_timed "$t" "$@" 2>/dev/null)
	death_ts=$(echo "$out" | grep "died" | head -1 | awk '{print $1}')
	if [ -z "$death_ts" ]; then
		echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
		fail_detail \
			"Ölüm hiç gerçekleşmedi" \
			"Filozof ${ttd}ms içinde ölmeli ve 'died' logu basılmalı" \
			"Hiçbir 'died' satırı yok"
		record_fail "$priority" "$desc"
		return
	fi
	local limit=$((ttd + 10))
	if [ "$death_ts" -le "$limit" ]; then
		echo -e "${GREEN}[PASS]${RESET} $desc (${death_ts}ms ≤ ${limit}ms)"
		((PASS++))
	else
		echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
		fail_detail \
			"Ölüm çok geç gerçekleşti — monitor thread yeterince hızlı değil" \
			"Ölüm en geç ${limit}ms'de (time_to_die + 10ms tolerans) loglanmalı" \
			"Ölüm ${death_ts}ms'de gerçekleşti (${$(( death_ts - limit ))}ms gecikme)"
		record_fail "$priority" "$desc"
	fi
}

check_state_order() {
	local priority="$1" desc="$2" t=$3 np=$4; shift 4
	show_cmd "$@"
	local out fail=0 bad_pid bad_prev bad_curr
	out=$(run_timed "$t" "$@" 2>/dev/null)
	for pid in $(seq 1 "$np"); do
		local prev_state=""
		while IFS= read -r state; do
			[ -z "$state" ] && continue
			if [ "$prev_state" = "is sleeping" ] && [ "$state" != "is thinking" ]; then
				fail=1; bad_pid=$pid; bad_prev=$prev_state; bad_curr=$state
				break 2
			fi
			prev_state="$state"
		done < <(echo "$out" | grep -E "^[0-9]+ $pid (is eating|is sleeping|is thinking)" \
			| awk '{$1=$2=""; print substr($0,3)}')
	done
	if [ "$fail" -eq 0 ]; then
		echo -e "${GREEN}[PASS]${RESET} $desc"
		((PASS++))
	else
		echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
		fail_detail \
			"Filozof $bad_pid'nin durum sırası bozuk: '$bad_prev' sonrası '$bad_curr' geldi" \
			"Sıra şöyle olmalı: is eating → is sleeping → is thinking → (tekrar)" \
			"Filozof $bad_pid: ...$bad_prev → $bad_curr..."
		record_fail "$priority" "$desc"
	fi
}

check_no_double_eating() {
	local priority="$1" desc="$2" t=$3 np=$4; shift 4
	show_cmd "$@"
	local out fail=0 bad_pid
	out=$(run_timed "$t" "$@" 2>/dev/null)
	for pid in $(seq 1 "$np"); do
		local prev=""
		while IFS= read -r state; do
			if [ "$prev" = "is eating" ] && [ "$state" = "is eating" ]; then
				fail=1; bad_pid=$pid
				break 2
			fi
			prev="$state"
		done < <(echo "$out" | grep -E "^[0-9]+ $pid (is eating|is sleeping|is thinking)" \
			| awk '{$1=$2=""; print substr($0,3)}')
	done
	if [ "$fail" -eq 0 ]; then
		echo -e "${GREEN}[PASS]${RESET} $desc"
		((PASS++))
	else
		echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
		fail_detail \
			"Filozof $bad_pid iki çatal bırakmadan tekrar yemek yedi — mutex sorunu olabilir" \
			"eating logları arasında mutlaka sleeping ve thinking geçmeli" \
			"Filozof $bad_pid: is eating → is eating (sleeping/thinking atlandı)"
		record_fail "$priority" "$desc"
	fi
}

check_no_simultaneous_forks() {
	local priority="$1" desc="$2" t=$3 np=$4; shift 4
	show_cmd "$@"
	local out fail=0 bad_ts bad_a bad_b
	out=$(run_timed "$t" "$@" 2>/dev/null)
	while IFS= read -r ts; do
		local eaters arr count
		eaters=$(echo "$out" | grep "^$ts .* is eating" | awk '{print $2}' | sort -n)
		count=$(echo "$eaters" | grep -c .)
		if [ "$count" -gt 1 ]; then
			arr=($eaters)
			for ((i=0; i<${#arr[@]}-1; i++)); do
				local a=${arr[$i]} b=${arr[$((i+1))]}
				local diff=$(( b - a ))
				if [ "$diff" -eq 1 ] || ( [ "$a" -eq 1 ] && [ "$b" -eq "$np" ] ); then
					fail=1; bad_ts=$ts; bad_a=$a; bad_b=$b
					break 2
				fi
			done
		fi
	done < <(echo "$out" | grep "is eating" | awk '{print $1}' | sort -u)
	if [ "$fail" -eq 0 ]; then
		echo -e "${GREEN}[PASS]${RESET} $desc"
		((PASS++))
	else
		echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
		fail_detail \
			"Komşu filozoflar ${bad_ts}ms'de aynı anda yemek yiyor — ortak çatalı paylaşıyorlar" \
			"Komşu iki filozof aynı anda eating durumunda olamaz (aynı çatal paylaşılıyor)" \
			"${bad_ts}ms: Filozof $bad_a ve Filozof $bad_b aynı anda eating"
		record_fail "$priority" "$desc"
	fi
}

# ============================================================
# TESTLER
# ============================================================

echo -e "\n${CYAN}══════════════════════════════════════════${RESET}"
echo -e "${CYAN}  PHILO TESTER — $(date '+%H:%M:%S')${RESET}"
echo -e "${CYAN}══════════════════════════════════════════${RESET}\n"

# ── BÖLÜM 1: GEÇERSİZ ARGÜMANLAR ──────────────────────────
echo -e "${YELLOW}[ GEÇERSİZ ARGÜMANLAR ]${RESET}"
expect_exit_nonzero  CRITICAL  "Argüman yok"
expect_exit_nonzero  CRITICAL  "1 argüman"                        1
expect_exit_nonzero  CRITICAL  "2 argüman"                        1 800
expect_exit_nonzero  CRITICAL  "3 argüman"                        1 800 200
expect_exit_nonzero  CRITICAL  "6 argüman (fazla)"                5 800 200 200 7 99
expect_exit_nonzero  CRITICAL  "Sıfır philo sayısı"               0 800 200 200
expect_exit_nonzero  CRITICAL  "Negatif philo sayısı"             -1 800 200 200
expect_exit_nonzero  CRITICAL  "Negatif time_to_die"              5 -800 200 200
expect_exit_nonzero  CRITICAL  "Negatif time_to_eat"              5 800 -200 200
expect_exit_nonzero  CRITICAL  "Negatif time_to_sleep"            5 800 200 -200
expect_exit_nonzero  CRITICAL  "Negatif must_eat_count"           5 800 200 200 -1
expect_exit_nonzero  CRITICAL  "Sıfır must_eat_count"             5 800 200 200 0
expect_exit_nonzero  MEDIUM    "Harf içeren argüman"              5 abc 200 200
expect_exit_nonzero  MEDIUM    "Çok büyük sayı (overflow)"        5 9999999999 200 200
expect_exit_nonzero  MEDIUM    "Noktalı sayı"                     5 800.5 200 200
expect_exit_nonzero  LOW       "Özel karakter"                    5 800 "@" 200

# ── BÖLÜM 2: TEK FİLOZOF ───────────────────────────────────
echo -e "\n${YELLOW}[ TEK FİLOZOF ]${RESET}"
expect_death              CRITICAL  "1 philo → ölmeli"              3  1 800 200 200
expect_death              CRITICAL  "1 philo kısa time_to_die"      3  1 100 200 200
expect_no_log_after_death CRITICAL  "1 philo ölüm sonrası log yok"  3  1 800 200 200

# ── BÖLÜM 3: ÖLÜM OLMAMALI ─────────────────────────────────
echo -e "\n${YELLOW}[ ÖLÜM OLMAMALI ]${RESET}"
sleep 1
expect_no_death  CRITICAL  "5 philo klasik"             8  5 800 200 200
sleep 1
expect_no_death  CRITICAL  "4 philo klasik"             8  4 800 200 200
sleep 1
expect_no_death  MEDIUM    "2 philo"                    8  2 800 200 200
sleep 1
expect_no_death  MEDIUM    "5 philo sıkı timing"       10  5 610 200 200
sleep 1
expect_no_death  MEDIUM    "4 philo sıkı timing"       10  4 410 200 200
sleep 1
expect_no_death  MEDIUM    "3 philo geniş margin"       8  3 1000 200 200
sleep 1
expect_no_death  MEDIUM    "2 philo eşit süreler"       8  2 500 200 200
sleep 1
expect_no_death  MEDIUM    "100 philo"                  8  100 800 200 200
sleep 1
expect_no_death  LOW       "200 philo"                  8  200 800 200 200

# ── BÖLÜM 4: ÖLÜM OLMALI ───────────────────────────────────
echo -e "\n${YELLOW}[ ÖLÜM OLMALI ]${RESET}"
expect_death  CRITICAL  "5 philo çok kısa time_to_die"        3  5 100 200 200
expect_death  CRITICAL  "3 philo time_to_die < time_to_eat"   3  3 100 200 200
expect_death  CRITICAL  "2 philo imkansız timing"             3  2 100 200 200
expect_death  MEDIUM    "5 philo time_to_die=310 (az margin)" 5  5 310 200 200

# ── BÖLÜM 5: MUST_EAT_COUNT ────────────────────────────────
echo -e "\n${YELLOW}[ MUST_EAT_COUNT ]${RESET}"
expect_clean_exit  CRITICAL  "5 philo 7 yemek → temiz çıkış"     10 5 800 200 200 7
expect_clean_exit  CRITICAL  "5 philo 1 yemek → temiz çıkış"      5 5 800 200 200 1
expect_clean_exit  CRITICAL  "2 philo 5 yemek → temiz çıkış"     10 2 800 200 200 5
expect_clean_exit  CRITICAL  "4 philo 3 yemek → temiz çıkış"     10 4 800 200 200 3
expect_no_death    CRITICAL  "5 philo 10 yemek ölüm olmamalı"    15 5 800 200 200 10
expect_clean_exit  LOW       "1 philo must_eat ama ölür"           5 1 800 200 200 5

# ── BÖLÜM 6: ÇIKTI FORMATI ─────────────────────────────────
echo -e "\n${YELLOW}[ ÇIKTI FORMATI ]${RESET}"
check_output_format  CRITICAL  "5 philo format kontrolü"  3 5 800 200 200
check_output_format  CRITICAL  "2 philo format kontrolü"  3 2 800 200 200
check_output_format  MEDIUM    "ölüm senaryosu format"    3 5 100 200 200

# ── BÖLÜM 7: ÖLÜM SONRASI LOG ──────────────────────────────
echo -e "\n${YELLOW}[ ÖLÜM SONRASI LOG ]${RESET}"
expect_no_log_after_death  CRITICAL  "5 philo ölüm sonrası log"  3 5 100 200 200
expect_no_log_after_death  CRITICAL  "3 philo ölüm sonrası log"  3 3 100 200 200
expect_no_log_after_death  MEDIUM    "2 philo ölüm sonrası log"  3 2 100 200 200

# ── BÖLÜM 8: STRES / UZUN SÜRELİ ──────────────────────────
echo -e "\n${YELLOW}[ STRES / UZUN SÜRELİ ]${RESET}"
expect_no_death  CRITICAL  "5 philo 10sn yaşıyor"    10 5 800 200 200
expect_no_death  MEDIUM    "4 philo 10sn yaşıyor"    10 4 800 200 200
expect_no_death  MEDIUM    "10 philo 10sn yaşıyor"   10 10 800 200 200
expect_no_exit   MEDIUM    "5 philo sonsuz döngü"     3 5 800 200 200

# ── BÖLÜM 9: SINIR DEĞERLERİ ───────────────────────────────
echo -e "\n${YELLOW}[ SINIR DEĞERLERİ ]${RESET}"
expect_no_death  MEDIUM    "time_to_die > eat+sleep (geniş margin)"  5 5 800 200 100
expect_death     CRITICAL  "time_to_die=1ms"                      3 5 1 200 200
expect_no_death  MEDIUM    "time_to_eat=1ms"                      3 5 800 1 200
expect_no_death  MEDIUM    "time_to_sleep=1ms"                    3 5 800 200 1
expect_no_death  MEDIUM    "hepsi 1ms (time_to_die yüksek)"       3 5 800 1 1
expect_no_death  LOW       "çok büyük zaman değerleri"            3 5 2147483647 200 200

# ── BÖLÜM 10: TUTARLILIK — 3x tekrar ───────────────────────
echo -e "\n${YELLOW}[ TUTARLILIK — 3x tekrar ]${RESET}"
for i in 1 2 3; do
	expect_no_death  CRITICAL  "5 800 200 200 — çalışma #$i"  4 5 800 200 200
done
for i in 1 2 3; do
	expect_death     CRITICAL  "5 100 200 200 — çalışma #$i"  3 5 100 200 200
done

# ── BÖLÜM 11: VALGRIND MEMORY LEAK ─────────────────────────
echo -e "\n${YELLOW}[ VALGRIND — MEMORY LEAK ]${RESET}"
check_valgrind  CRITICAL  "5 philo must_eat → leak yok"   12 5 800 200 200 3
check_valgrind  CRITICAL  "2 philo must_eat → leak yok"   10 2 800 200 200 2
check_valgrind  CRITICAL  "Ölüm senaryosu → leak yok"      5 5 100 200 200
check_valgrind  MEDIUM    "1 philo → leak yok"             3 1 800 200 200
check_valgrind  MEDIUM    "Geçersiz argüman → leak yok"    3 0 800 200 200

# ── BÖLÜM 12: ÖLÜM ZAMANLAMA ────────────────────────────────
echo -e "\n${YELLOW}[ ÖLÜM ZAMANLAMA ]${RESET}"
check_death_timing  CRITICAL  "1 philo 800ms içinde ölmeli"  3 800  1 800 200 200
check_death_timing  CRITICAL  "1 philo 200ms içinde ölmeli"  3 200  1 200 200 200
check_death_timing  MEDIUM    "1 philo 100ms içinde ölmeli"  3 100  1 100 50  50
check_death_timing  MEDIUM    "5 philo 310ms içinde ölmeli"  5 310  5 310 200 200

# ── BÖLÜM 13: DURUM SIRASI ──────────────────────────────────
echo -e "\n${YELLOW}[ DURUM SIRASI — eating→sleeping→thinking ]${RESET}"
check_state_order  MEDIUM  "5 philo durum sırası"  5 5 5 800 200 200
check_state_order  MEDIUM  "4 philo durum sırası"  5 4 4 800 200 200
check_state_order  MEDIUM  "2 philo durum sırası"  5 2 2 800 200 200
check_state_order  LOW     "3 philo durum sırası"  5 3 3 1000 200 200

# ── BÖLÜM 14: ÇİFT EATING / FORK ÇAKIŞMASI ─────────────────
echo -e "\n${YELLOW}[ ÇİFT EATING / FORK ÇAKIŞMASI ]${RESET}"
check_no_double_eating       CRITICAL  "5 philo çift eating yok"          5 5 5 800 200 200
check_no_double_eating       CRITICAL  "4 philo çift eating yok"          5 4 4 800 200 200
check_no_double_eating       MEDIUM    "2 philo çift eating yok"          5 2 2 800 200 200
check_no_simultaneous_forks  CRITICAL  "5 philo komşu aynı anda yemiyor"  5 5 5 800 200 200
check_no_simultaneous_forks  MEDIUM    "4 philo komşu aynı anda yemiyor"  5 4 4 800 200 200

# ── BÖLÜM 15: MUST_EAT DOĞRULUĞU ───────────────────────────
# Her filozofun gerçekten must_eat_count kadar yiyip yemediğini log'dan sayarak kontrol eder
echo -e "\n${YELLOW}[ MUST_EAT DOĞRULUĞU ]${RESET}"

check_meal_count() {
	local priority="$1" desc="$2" t=$3 np=$4 expected=$5; shift 5
	show_cmd "$@"
	local out
	out=$(run_timed "$t" "$@" 2>/dev/null)
	local fail=0 bad_pid bad_got
	for pid in $(seq 1 "$np"); do
		local count
		count=$(echo "$out" | grep -E "^[0-9]+ $pid is eating$" | wc -l)
		if [ "$count" -lt "$expected" ]; then
			fail=1; bad_pid=$pid; bad_got=$count
			break
		fi
	done
	if [ "$fail" -eq 0 ]; then
		echo -e "${GREEN}[PASS]${RESET} $desc"
		((PASS++))
	else
		echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
		fail_detail \
			"Filozof $bad_pid yeterince yemedi" \
			"Her filozofun tam $expected kez 'is eating' logu olmalı" \
			"Filozof $bad_pid sadece $bad_got kez yedi"
		record_fail "$priority" "$desc"
	fi
}

check_meal_count  CRITICAL  "5 philo 3 yemek — hepsi 3 kez yedi mi"   12 5 3  5 800 200 200 3
check_meal_count  CRITICAL  "5 philo 1 yemek — hepsi 1 kez yedi mi"    5 5 1  5 800 200 200 1
check_meal_count  CRITICAL  "2 philo 5 yemek — hepsi 5 kez yedi mi"   12 2 5  2 800 200 200 5
check_meal_count  MEDIUM    "4 philo 2 yemek — hepsi 2 kez yedi mi"    8 4 2  4 800 200 200 2

# ── BÖLÜM 16: TIMESTAMP MONOTONİK ───────────────────────────
# Timestamp'ler her zaman artıyor mu, geriye gidiyor mu kontrol eder
echo -e "\n${YELLOW}[ TIMESTAMP MONOTONİK ]${RESET}"

check_timestamp_monotonic() {
	local priority="$1" desc="$2" t=$3; shift 3
	show_cmd "$@"
	local out
	out=$(run_timed "$t" "$@" 2>/dev/null)
	local prev_ts=0 fail=0 bad_prev bad_curr
	# 10ms tolerans: birden fazla thread aynı ms'de yazabilir,
	# ama timestamp onlarca ms geriye gidemez
	local TOLERANCE=10
	while IFS= read -r ts; do
		if [ "$ts" -lt $((prev_ts - TOLERANCE)) ]; then
			fail=1; bad_prev=$prev_ts; bad_curr=$ts
			break
		fi
		prev_ts=$ts
	done < <(echo "$out" | awk '{print $1}' | grep -E '^[0-9]+$')
	if [ "$fail" -eq 0 ]; then
		echo -e "${GREEN}[PASS]${RESET} $desc"
		((PASS++))
	else
		echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
		fail_detail \
			"Timestamp ${TOLERANCE}ms'den fazla geriye gitti: ${bad_prev}ms → ${bad_curr}ms" \
			"Her log satırının timestamp'i öncekinden en fazla ${TOLERANCE}ms küçük olabilir" \
			"${bad_prev}ms sonrası ${bad_curr}ms geldi (fark: $((bad_prev - bad_curr))ms)"
		record_fail "$priority" "$desc"
	fi
}

check_timestamp_monotonic  CRITICAL  "5 philo timestamp monoton"   5 5 800 200 200
check_timestamp_monotonic  CRITICAL  "2 philo timestamp monoton"   5 2 800 200 200
check_timestamp_monotonic  MEDIUM    "ölüm senaryosu timestamp"    3 5 100 200 200

# ── BÖLÜM 17: FORK LOG SAYISI ────────────────────────────────
# Her eating öncesi tam 2 fork logu var mı kontrol eder
echo -e "\n${YELLOW}[ FORK LOG SAYISI ]${RESET}"

check_fork_count_per_meal() {
	local priority="$1" desc="$2" t=$3 np=$4; shift 4
	show_cmd "$@"
	local out
	out=$(run_timed "$t" "$@" 2>/dev/null)
	local fail=0 bad_pid bad_meal bad_forks

	for pid in $(seq 1 "$np"); do
		# Her filozofun satırlarını sırayla al
		local meal_num=0 fork_count=0 prev_was_fork=0
		while IFS= read -r line; do
			if echo "$line" | grep -q "has taken a fork"; then
				((fork_count++))
			elif echo "$line" | grep -q "is eating"; then
				((meal_num++))
				if [ "$fork_count" -ne 2 ]; then
					fail=1; bad_pid=$pid; bad_meal=$meal_num; bad_forks=$fork_count
					break 2
				fi
				fork_count=0
			fi
		done < <(echo "$out" | grep -E "^[0-9]+ $pid ")
	done

	if [ "$fail" -eq 0 ]; then
		echo -e "${GREEN}[PASS]${RESET} $desc"
		((PASS++))
	else
		echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
		fail_detail \
			"Filozof $bad_pid, ${bad_meal}. yemekte $bad_forks çatal logu attı (2 olmalı)" \
			"Her eating öncesi tam 2 adet 'has taken a fork' logu olmalı" \
			"Filozof $bad_pid: yemek #$bad_meal için $bad_forks fork logu"
		record_fail "$priority" "$desc"
	fi
}

check_fork_count_per_meal  CRITICAL  "5 philo her eating için 2 fork"  5 5 5 800 200 200
check_fork_count_per_meal  CRITICAL  "4 philo her eating için 2 fork"  5 4 4 800 200 200
check_fork_count_per_meal  MEDIUM    "2 philo her eating için 2 fork"  5 2 2 800 200 200

# ── BÖLÜM 18: ÇİFT/TEK STAGGER ─────────────────────────────
# Çift id'li filozoflar başlangıçta geç mi başlıyor (deadlock önlemi)
echo -e "\n${YELLOW}[ ÇİFT/TEK STAGGER ]${RESET}"

check_even_stagger() {
	local priority="$1" desc="$2" t=$3 np=$4 time_to_eat=$5; shift 5
	show_cmd "$@"
	local out
	out=$(run_timed "$t" "$@" 2>/dev/null)

	# Tek filozofların ilk eating timestamp'i
	local first_odd first_even fail=0
	first_odd=$(echo "$out" | awk '{print $1, $2, $3}' | grep "is eating" | \
		awk '($2 % 2 == 1) {print $1}' | head -1)
	first_even=$(echo "$out" | awk '{print $1, $2, $3}' | grep "is eating" | \
		awk '($2 % 2 == 0) {print $1}' | head -1)

	if [ -z "$first_odd" ] || [ -z "$first_even" ]; then
		echo -e "${YELLOW}[SKIP]${RESET} $desc (yeterli veri yok)"
		return
	fi

	# Çift filozoflar tek filozoflardan time_to_eat kadar sonra yemeli
	local diff=$(( first_even - first_odd ))
	local min_delay=$(( time_to_eat / 2 ))

	if [ "$diff" -ge "$min_delay" ]; then
		echo -e "${GREEN}[PASS]${RESET} $desc (çift filozoflar ${diff}ms sonra başladı)"
		((PASS++))
	else
		echo -e "${RED}[FAIL]${RESET} $(priority_label "$priority") $desc"
		fail_detail \
			"Çift id'li filozoflar tek id'lilerle neredeyse aynı anda yemek yedi — stagger çalışmıyor olabilir" \
			"Çift filozoflar en az ${min_delay}ms sonra yemek yemeli (deadlock önlemi)" \
			"Fark sadece ${diff}ms (tek: ${first_odd}ms, çift: ${first_even}ms)"
		record_fail "$priority" "$desc"
	fi
}

check_even_stagger  MEDIUM  "5 philo çift/tek stagger"  5 5 200  5 800 200 200
check_even_stagger  MEDIUM  "4 philo çift/tek stagger"  5 4 200  4 800 200 200

# ============================================================
# SONUÇ
# ============================================================

TOTAL=$((PASS + FAIL))
echo -e "\n${CYAN}══════════════════════════════════════════${RESET}"
echo -e "  Toplam: $TOTAL  |  ${GREEN}Geçti: $PASS${RESET}  |  ${RED}Kaldı: $FAIL${RESET}"
echo -e "${CYAN}══════════════════════════════════════════${RESET}"

if [ ${#CRITICAL_FAILS[@]} -gt 0 ]; then
	echo -e "\n${RED}${BOLD}🔴 CRITICAL — Mutlaka fix et (${#CRITICAL_FAILS[@]} adet):${RESET}"
	for e in "${CRITICAL_FAILS[@]}"; do
		echo -e "  ${RED}✗${RESET} $e"
	done
fi

if [ ${#MEDIUM_FAILS[@]} -gt 0 ]; then
	echo -e "\n${YELLOW}${BOLD}🟡 MEDIUM — Fixlersen iyi olur (${#MEDIUM_FAILS[@]} adet):${RESET}"
	for e in "${MEDIUM_FAILS[@]}"; do
		echo -e "  ${YELLOW}✗${RESET} $e"
	done
fi

if [ ${#LOW_FAILS[@]} -gt 0 ]; then
	echo -e "\n${MAGENTA}${BOLD}🟣 LOW — Küçük sorun, zorunlu değil (${#LOW_FAILS[@]} adet):${RESET}"
	for e in "${LOW_FAILS[@]}"; do
		echo -e "  ${MAGENTA}✗${RESET} $e"
	done
fi

if [ ${#CRITICAL_FAILS[@]} -eq 0 ] && [ ${#MEDIUM_FAILS[@]} -eq 0 ] && [ ${#LOW_FAILS[@]} -eq 0 ]; then
	echo -e "\n${GREEN}${BOLD}✓ Tüm testler geçti!${RESET}"
fi

echo ""
[ "${#CRITICAL_FAILS[@]}" -eq 0 ] && exit 0 || exit 1