$code = @"
using System;
using System.Drawing;
using System.Drawing.Imaging;

public class ImageProcessor {
    public static void MakeTransparent(string imagePath, string outPath) {
        Bitmap bmp = new Bitmap(imagePath);
        Bitmap transparentBmp = new Bitmap(bmp.Width, bmp.Height);
        
        for (int y = 0; y < bmp.Height; y++) {
            for (int x = 0; x < bmp.Width; x++) {
                Color c = bmp.GetPixel(x, y);
                if (c.R > 235 && c.G > 235 && c.B > 235) {
                    transparentBmp.SetPixel(x, y, Color.Transparent);
                } else {
                    int maxColor = Math.Max(c.R, Math.Max(c.G, c.B));
                    if (maxColor > 180) {
                        int alpha = 255 - (maxColor - 180) * 255 / 75;
                        if (alpha < 0) alpha = 0;
                        if (alpha > 255) alpha = 255;
                        transparentBmp.SetPixel(x, y, Color.FromArgb(alpha, c.R, c.G, c.B));
                    } else {
                        transparentBmp.SetPixel(x, y, c);
                    }
                }
            }
        }
        bmp.Dispose();
        transparentBmp.Save(outPath, ImageFormat.Png);
        transparentBmp.Dispose();
    }
}
"@
Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$inPath = Join-Path $dir "logo.png"
$outPath = Join-Path $dir "logo_out.png"
[ImageProcessor]::MakeTransparent($inPath, $outPath)
Move-Item -Path $outPath -Destination $inPath -Force
