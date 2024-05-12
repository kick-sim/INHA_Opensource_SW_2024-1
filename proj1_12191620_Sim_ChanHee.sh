#!/bin/bash

#6번문제
find_largest_difference() {
    local team_name=$1
    local team_number=$2
    local matches_file="matches.csv"
    
    # 해당 팀의 홈 경기 결과만 필터링
    local home_matches=$(awk -F ',' -v team="$team_name" '$3 == team' "$matches_file")

    # 가장 큰 득점 차이 초기화
    local largest_difference=0

    # 가장 큰 득점 차이로 승리한 경기를 저장할 배열
    local winning_matches=()

    # home_matches 파일 내 각 경기에 대한 반복
    while IFS=',' read -r date_GMT attendance home_team_name away_team_name home_team_goal_count away_team_goal_count stadium_name; do
        difference=$((home_team_goal_count - away_team_goal_count))

        # 현재 경기의 득점 차이가 가장 큰 득점 차이보다 큰지 확인
        if (( difference > largest_difference )); then
            largest_difference=$difference
            winning_matches=("$date_GMT")
            winning_matches+=("$home_team_name $home_team_goal_count vs $away_team_goal_count $away_team_name")
            winning_matches+=(" ")
        elif (( difference == largest_difference )); then
            winning_matches+=("$date_GMT")
            winning_matches+=("$home_team_name $home_team_goal_count vs $away_team_goal_count $away_team_name")
            winning_matches+=(" ")
        fi
    done <<< "$home_matches"

    # 출력: 특정 팀이 홈 스타디움에서 가장 큰 득점 차이로 승리한 모든 경기
    echo " "
    for match in "${winning_matches[@]}"; do
        echo "$match"
    done
}

#6번문제 메뉴 선택
find_largest_difference_team_menu() {
    local teams_file="teams.csv"

    # 메뉴 출력
    echo "Select your team:"
    local counter=0
    awk -F ',' 'NR > 1 {print $1}' "$teams_file" | while IFS= read -r name; do counter=$((counter + 1))
    echo "$counter) $name"
    done

    # 팀 선택
    read -p "Enter your team number: " team_number
    # 선택된 팀에 대한 이름 할당
    local team_name=$(awk -F ',' -v team_num="$team_number"  'NR == team_num + 1{print $1}' "$teams_file")
    if [[ -z $team_name ]]; then
        echo "Invalid team number!"
        exit 1
    fi

    # 특정 팀이 홈 스타디움에서 가장 큰 득점 차이로 승리한 모든 경기를 찾아 출력
    find_largest_difference "$team_name" "$team_number"
}







print_header() {
    echo "************OSS1 - Project1************"
    echo "* StudentID : 12191620 "
    echo "* Name : Sim ChanHee "
    echo "*****************************************"
}

print_menu() {
    echo "[MENU]"
    echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
    echo "2. Get the team data to enter a league position in teams.csv"
    echo "3. Get the Top-3 Attendance matches in matches.csv"
    echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
    echo "5. Get the modified format of date_GMT in matches.csv"
    echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
    echo "7. Exit"
}
#1번문제
get_sonny_data() {
    read -p "Do you want to get the Heung-Min Son's data?(y/n) " answer
    if [ "$answer" = "y" ]; then
        awk -F ',' '$1=="Heung-Min Son" {print "Current Club: " $4 ", Appearances: " $6 ", Goals: " $7 ", Assists: " $8}' players.csv
    else
        echo "you chose no!"
    fi
}
#2번문제
get_team_data_by_position() {
    read -p "What do you want to get the team data of league_position[1~20] : " position
    total_matches=$2+$3+$4;
    win_rate=($2 / total_matches);
    awk -F ',' -v pos="$position" '$6==pos {total_matches=$2+$3+$4;
    win_rate=($2 / total_matches);
    print $6, $1, win_rate}' teams.csv
}
#3번문제
get_top3_attendance_matches() {
    read -p "Do you want to know Top-3 attendance data and average attendance? (y/n) :" answer
    if [ "$answer" = "y" ]; then
        echo "***Top 3 Attendance Matches***"
        sort -t',' -k2,2nr matches.csv | head -n 3 | awk -F ',' '{print $3 " vs. " $4 " (" $1 ")"; print $2 " " $7}'
    else
        echo "you chose no!"
    fi
}
#4번문제
get_team_position_and_top_scorer() {
    read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n) : " answer
    if [ "$answer" = "y" ]; then
        awk -F ',' 'NR>1 {team[$6] = $1} END {
            for (t in team) {
                team_name = team[t]
                top_scorer_goals = 0
                while ((getline < "players.csv") > 0) {
                    if ($4 == team[t] && $7 > top_scorer_goals) {
                        top_scorer_goals = $7
                        top_scorer_name = $1
                    }
                }
                close("players.csv")
                team_position = t
                {print team_position, team_name;
                print top_scorer_name, top_scorer_goals;print " "}
            }
        }' teams.csv
    else
        echo "you chose no!"
    fi
}
#5번문제
modify_date_format() {
     read -p "Do you want to modify the format of date? (y/n) : " answer
    if [ "$answer" = "y" ]; then
        sed -E 's/Jan/01/; s/Feb/02/; s/Mar/03/; s/Apr/04/; s/May/05/; s/Jun/06/; s/Jul/07/; s/Aug/08/; s/Sep/09/; s/Oct/10/; s/Nov/11/; s/Dec/12/' matches.csv | awk -F ' - ' '{split($1,a," "); print a[3] "/" a[2] "/" a[1] " " $2}' | awk -F ',' '{print $1}' | head -n 10
    else
        echo "you chose no!"
    fi
}

if [ ! -f "$1" ] || [ ! -f "$2" ] || [ ! -f "$3" ]; then
    echo "usage: ./2024-OSS-Project1.sh file1 file2 file3"
    exit 1
fi

print_header

while :
do
    print_menu
    read -p "Enter your choice: " choice
    case $choice in
        1) get_sonny_data ;;
        2) get_team_data_by_position ;;
        3) get_top3_attendance_matches ;;
        4) get_team_position_and_top_scorer ;;
        5) modify_date_format ;;
        6) find_largest_difference_team_menu;;
        7) echo "Exit!"; exit ;;
    esac
done
