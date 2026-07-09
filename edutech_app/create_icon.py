from PIL import Image, ImageDraw
import math

# Create 1024x1024 image (standard app icon size)
size = 1024
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Colors
primary = (33, 150, 243)      # Blue
secondary = (76, 175, 80)     # Green
accent = (255, 193, 7)        # Amber
white = (255, 255, 255)
dark = (33, 33, 33)

# Background circle
center = size // 2
radius = size // 2 - 20
draw.ellipse([20, 20, size-20, size-20], fill=primary)

# Draw book (left side)
book_x, book_y = 280, 500
book_w, book_h = 200, 280

# Book cover
draw.rounded_rectangle([book_x, book_y, book_x + book_w, book_y + book_h], 15, fill=white)
draw.rounded_rectangle([book_x + 10, book_y + 10, book_x + book_w - 10, book_y + book_h - 10], 10, fill=(240, 240, 240))

# Book spine
draw.rectangle([book_x, book_y, book_x + 25, book_y + book_h], fill=secondary)

# Book lines (text simulation)
for i in range(6):
    line_y = book_y + 50 + i * 35
    draw.rectangle([book_x + 45, line_y, book_x + 160, line_y + 15], fill=(200, 200, 200))

# Graduation cap (top center)
cap_center_x = size // 2 + 50
cap_y = 320

# Cap base (diamond shape)
cap_w = 280
cap_h = 140
points = [
    (cap_center_x - cap_w//2, cap_y),
    (cap_center_x, cap_y + cap_h//2),
    (cap_center_x + cap_w//2, cap_y),
    (cap_center_x, cap_y - cap_h//2),
]
draw.polygon(points, fill=white)

# Cap top
draw.polygon([
    (cap_center_x - cap_w//2 - 20, cap_y + 20),
    (cap_center_x, cap_y + cap_h//2 + 20),
    (cap_center_x + cap_w//2 + 20, cap_y + 20),
    (cap_center_x, cap_y - cap_h//2 - 40),
], fill=white)

# Cap button (top center)
draw.ellipse([cap_center_x - 20, cap_y - cap_h//2 - 50, cap_center_x + 20, cap_y - cap_h//2 - 10], fill=accent)

# Tassel
tassel_x = cap_center_x + cap_w//2 + 15
tassel_top = cap_y + 20
draw.line([(tassel_x, tassel_top), (tassel_x + 60, tassel_top + 150)], fill=accent, width=12)
draw.ellipse([tassel_x + 45, tassel_top + 140, tassel_x + 75, tassel_top + 180], fill=accent)

# Pencil (right side)
pencil_x = 680
pencil_y = 480

# Pencil body
draw.rectangle([pencil_x, pencil_y, pencil_x + 60, pencil_y + 300], fill=(255, 215, 0))  # Yellow

# Pencil tip
draw.polygon([
    (pencil_x, pencil_y + 300),
    (pencil_x + 30, pencil_y + 360),
    (pencil_x + 60, pencil_y + 300),
], fill=(255, 200, 150))  # Wood color

# Pencil tip point
draw.polygon([
    (pencil_x + 20, pencil_y + 320),
    (pencil_x + 30, pencil_y + 360),
    (pencil_x + 40, pencil_y + 320),
], fill=dark)  # Lead

# Pencil eraser
draw.rectangle([pencil_x - 5, pencil_y - 30, pencil_x + 65, pencil_y + 10], fill=(255, 100, 100))

# Pencil band
draw.rectangle([pencil_x - 5, pencil_y, pencil_x + 65, pencil_y + 15], fill=(200, 200, 200))

# Save
img.save('D:/TQLCNTT2311074/Nam3HK3/QuizEdu/edutech_app/assets/icon.png')
print("Icon created: assets/icon.png (1024x1024)")

# Also create smaller versions for Android
for scale, name in [(1.0, 'xxxhdpi'), (0.75, 'xxhdpi'), (0.5, 'xhdpi'), (0.375, 'hdpi'), (0.25, 'mdpi')]:
    new_size = int(512 * scale)
    resized = img.resize((new_size, new_size), Image.Resampling.LANCZOS)
    resized.save(f'D:/TQLCNTT2311074/Nam3HK3/QuizEdu/edutech_app/assets/{name}.png')
    print(f"Created {name}.png ({new_size}x{new_size})")

print("Done!")
