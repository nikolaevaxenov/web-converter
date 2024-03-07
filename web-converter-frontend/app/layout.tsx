import { Providers } from "./providers";
import Head from "./head";
import "@/styles/globals.css";
import { Toaster } from "@/components/ui/toaster";

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <Head />
      <body>
        <Providers>
          <div>
            <main>{children}</main>
            <Toaster />
          </div>
        </Providers>
      </body>
    </html>
  );
}
