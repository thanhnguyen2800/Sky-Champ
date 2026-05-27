📖 Giới thiệu
Invaders512 là bản cài đặt trò chơi Space Invaders kinh điển, được viết hoàn toàn bằng x86 Assembly và có kích thước nhỏ đến mức có thể nhét vừa vào một boot sector 512 bytes. Game chạy trên chế độ đồ hoạ VGA 320×200×256 màu (Mode 13h).

✨ Tính năng

🎮 Gameplay hoàn chỉnh — 55 invader trên 5 hàng, di chuyển và tấn công

🔫 Invader có thể bắn lại — đạn invader rơi ngẫu nhiên xuống người chơi

💥 Hiệu ứng nổ — cả tàu vũ trụ và invader đều có animation nổ

🛡️ Hàng rào chắn đạn — 5 barrier bảo vệ người chơi

⚡ Tốc độ tăng dần — invader tăng tốc khi bị tiêu diệt bớt

🏆 Hiển thị điểm số — điểm hiện tại luôn hiển thị ở góc trái trên 


🕹️ Điều khiển
Phím	Hành động
Ctrl	Di chuyển trái
Alt	Di chuyển phải
Shift	Bắn
Scroll Lock	Thoát game (chế độ COM)

🏆 Hệ thống điểm
Mỗi invader bị tiêu diệt = +1 điểm.
Điểm số được hiển thị dạng 3 chữ số (000–999) tại góc trái trên cùng màn hình, cập nhật theo thời gian thực.

🛠️ Yêu cầu & Build
Công cụ cần thiết
NASM — Netwide Assembler
DOSBox — để chạy file .COM
dd hoặc Rufus — để tạo USB bootable (tuỳ chọn)
Build file COM (chạy trên DOS/DOSBox)

bash
nasm -f bin -D com_file=1 invaders.asm -o invaders.com
Build boot sector (bootable USB/floppy)

bash
nasm -f bin invaders.asm -o invaders.bin
Ghi vào USB (Linux/macOS)

bash
dd if=invaders.bin of=floppy.img bs=512 count=1 conv=notrunc
Chạy trên DOSBox

dosbox invaders.com
📁 Cấu trúc dự án


invaders512/
├── invaders.asm        # Source code Assembly chính
├── invaders.com        # Binary COM (sau khi build)
├── invaders.bin        # Boot sector binary (sau khi build)
├── screenshot.png      # Ảnh chụp màn hình gameplay
└── README.md           # File này
