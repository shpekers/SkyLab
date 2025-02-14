import customtkinter as ctk
import psutil
import subprocess
import os
import webbrowser

ctk.set_appearance_mode("dark")
app = ctk.CTk()
app.title("SkyLab")
app.geometry("350x350")
app.resizable(False, False)
app.iconbitmap("assets/icon.ico")

tabview = ctk.CTkTabview(app, width=400, height=400)
tabview.pack(pady=20, padx=10)

tabview.add("Главная"), 
tabview.add("Другое")

header_label = ctk.CTkLabel(tabview.tab("Главная"), text="PaneL", font=("Arial", 24))
header_label.pack(pady=20)

status_frame = ctk.CTkFrame(tabview.tab("Главная"), fg_color="#1c1c1c")
status_frame.pack(pady=10, padx=50, fill="x")

status_label = ctk.CTkLabel(status_frame, text="Не установлена", font=("Segoe UI Emoji", 16))
status_label.pack(pady=10, padx=10)

def reload_btn():
    if "Служба запущена" in check_service_status():
        pause_button.pack(pady=10)  # Скрыть кнопку при запуске
        method_menu.pack_forget()
        start_button.pack_forget()
        settings_label2.pack(pady=(35, 5))
        remove_button.pack(pady=10)
        site_button.pack(pady=10)
    elif "Служба приостановлена" in check_service_status(): 
        pause_button.pack_forget()
        method_menu.pack_forget()
        start_button.pack(pady=10)
        settings_label2.pack(pady=(35, 5))
        remove_button.pack(pady=10)
        site_button.pack(pady=10)
    elif "Служба не установлена" in check_service_status():
        pause_button.pack_forget()
        start_button.pack_forget()
        method_menu.pack(pady=10)
        settings_label2.pack_forget()
        remove_button.pack_forget()

def check_service_status():
    service_name = "SkyLab"
    status = "Служба не установлена"

    for service in psutil.win_service_iter():
        if service.name() == service_name:
            status = "Служба запущена" if service.status() == "running" else "Служба приостановлена"
            break
    return status

def update_status():
    status = check_service_status()
    status_label.configure(text=f"{status}")

    app.after(1000, update_status)
    app.after(100, reload_btn)

update_status()

def run_script(script_name):
    script_path = os.path.join("scripts", f"{script_name}.bat")
    if os.path.exists(script_path):
        subprocess.Popen(script_path, shell=True)
    else:
        print(f"Скрипт {script_name}.bat не найден.")

methods = ["Основной", "Резервный 1", "Резервный 2", "Резервный 3", "Резервный 4", "Резервный 5", "Резервный 6", "Резервный 7", "Только Discord"]

selected_method = ctk.StringVar(value="Выберите метод")

def on_method_selected(selected):
    if selected!= "Выберите метод":
        run_script(selected.lower().replace(" ", "_"))

method_menu = ctk.CTkOptionMenu(tabview.tab("Главная"), variable=selected_method, values=methods, command=on_method_selected, width=200, height=30)
method_menu.pack(pady=20)


def run_pause():
    run_script("service_pause")
pause_button = ctk.CTkButton(tabview.tab("Главная"), text="Приостановить", command=run_pause)
pause_button.pack_forget()

def run_start():
    run_script("service_start")
start_button = ctk.CTkButton(tabview.tab("Главная"), text="Запустить", command=run_start)
start_button.pack_forget()

settings_label = ctk.CTkLabel(tabview.tab("Другое"), text="Информация", font=("Arial", 24))
settings_label.pack(pady=20)
settings_label = ctk.CTkLabel(tabview.tab("Другое"), text="Версия: 3.0.1", font=("Arial", 16))
settings_label.pack()
def run_site():
    webbrowser.open("http://shpekers.ru")
site_button = ctk.CTkButton(tabview.tab("Другое"), text="Сайт", command=run_site)
site_button.pack(pady=10)

settings_label2 = ctk.CTkLabel(tabview.tab("Другое"), text="Если Вы желаете изменить метод или же удалить \n службу, просто нажмите на кнопку ниже...", font=("Arial", 12))
settings_label2.pack(pady=(35, 5)) 

def run_remove():
    run_script("service_remove")
remove_button = ctk.CTkButton(tabview.tab("Другое"), text="Удалить", command=run_remove)
remove_button.pack()

app.mainloop()