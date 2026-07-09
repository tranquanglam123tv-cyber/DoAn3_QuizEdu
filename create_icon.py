from PIL import Image, ImageDraw
import os

def create_graduation_cap_icon():
    # Kích thước 1024x1024
    size = 1024
    img = Image.new('RGBA', (size, size), (255, 255, 255, 255))
    draw = ImageDraw.Draw(img)
    
    # Màu xanh lá (tương tự Flask logo)
    green = '#00A86B'
    
    # Vẽ mũ cử nhân (graduation cap)
    # Phần đế (vuông) của mũ
    cap_width = 500
    cap_height = 120
    cap_left = (size - cap_width) // 2
    cap_top = 400
    
    # Vẽ phần đế hình thang của mũ
    draw.polygon([
        (cap_left, cap_top),                          # trái trên
        (cap_left + cap_width, cap_top),              # phải trên  
        (cap_left + cap_width + 50, cap_top + cap_height),  # phải dưới
        (cap_left - 50, cap_top + cap_height),        # trái dưới
    ], fill=green)
    
    # Vẽ phần trên của mũ (tam giác)
    draw.polygon([
        (size // 2, 200),                             # đỉnh
        (cap_left + 100, cap_top + 30),               # trái
        (cap_left + cap_width - 100, cap_top + 30),    # phải
    ], fill=green)
    
    # Vẽ đường thẳng trên mũ (nơi tassel buộc)
    draw.line([(size // 2, 200), (size // 2, 550)], fill=green, width=15)
    
    # Vẽ tassel (dải ruy băng)
    tassel_width = 60
    tassel_height = 150
    tassel_left = cap_left + cap_width // 2 - tassel_width // 2
    tassel_top = 550
    
    # Thân tassel
    draw.rectangle([tassel_left, tassel_top, tassel_left + tassel_width, tassel_top + tassel_height], 
                   fill='#FFD700')  # Vàng
    
    # Đầu tassel (hình tròn nhỏ)
    draw.ellipse([tassel_left - 10, tassel_top - 20, 
                  tassel_left + tassel_width + 10, tassel_top + 30], 
                 fill='#FFD700')
    
    # Vẽ viền ngoài tròn (border)
    draw.ellipse([2, 2, size-2, size-2], outline='#E0E0E0', width=3)
    
    return img

def create_icon_set():
    # Tạo icon gốc
    icon = create_graduation_cap_icon()
    
    # Các kích thước cho Android
    sizes = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
        'icon': 512,  # icon.png chính
    }
    
    base_path = r'd:\TQLCNTT2311074\Nam3HK3\QuizEdu\edutech_app'
    
    for name, size in sizes.items():
        resized = icon.resize((size, size), Image.Resampling.LANCZOS)
        
        # Save to assets folder
        if name == 'icon':
            resized.save(f'{base_path}\\assets\\{name}.png', 'PNG')
        else:
            resized.save(f'{base_path}\\assets\\{name}.png', 'PNG')
        
        # Android mipmap folders (chỉ các kích thước chuẩn)
        if name in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']:
            mipmap_dir = f'{base_path}\\android\\app\\src\\main\\res\\mipmap-{name}'
            os.makedirs(mipmap_dir, exist_ok=True)
            drawable_path = f'{mipmap_dir}\\ic_launcher.png'
            resized.save(drawable_path, 'PNG')
        
        print(f'Created: {name} ({size}x{size})')
    
    # Tạo adaptive icon background (trắng)
    bg = Image.new('RGBA', (1024, 1024), (255, 255, 255, 255))
    bg.save(f'{base_path}\\android\\app\\src\\main\\res\\drawable-hdpi\\ic_launcher_background.png', 'PNG')
    bg.save(f'{base_path}\\android\\app\\src\\main\\res\\drawable-mdpi\\ic_launcher_background.png', 'PNG')
    bg.save(f'{base_path}\\android\\app\\src\\main\\res\\drawable-xhdpi\\ic_launcher_background.png', 'PNG')
    bg.save(f'{base_path}\\android\\app\\src\\main\\res\\drawable-xxhdpi\\ic_launcher_background.png', 'PNG')
    bg.save(f'{base_path}\\android\\app\\src\\main\\res\\drawable-xxxhdpi\\ic_launcher_background.png', 'PNG')
    
    # Foreground
    icon.save(f'{base_path}\\android\\app\\src\\main\\res\\drawable-hdpi\\ic_launcher_foreground.png', 'PNG')
    icon.save(f'{base_path}\\android\\app\\src\\main\\res\\drawable-mdpi\\ic_launcher_foreground.png', 'PNG')
    icon.save(f'{base_path}\\android\\app\\src\\main\\res\\drawable-xhdpi\\ic_launcher_foreground.png', 'PNG')
    icon.save(f'{base_path}\\android\\app\\src\\main\\res\\drawable-xxhdpi\\ic_launcher_foreground.png', 'PNG')
    icon.save(f'{base_path}\\android\\app\\src\\main\\res\\drawable-xxxhdpi\\ic_launcher_foreground.png', 'PNG')
    
    # Tạo adaptive icon XML
    mipmap_dir = f'{base_path}\\android\\app\\src\\main\\res\\mipmap-anydpi-v26'
    os.makedirs(mipmap_dir, exist_ok=True)
    
    xml_content = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>'''
    
    with open(f'{mipmap_dir}\\ic_launcher.xml', 'w') as f:
        f.write(xml_content)
    
    print(f'Created adaptive icon XML')

if __name__ == '__main__':
    create_icon_set()
    print('Done! All icons created.')
