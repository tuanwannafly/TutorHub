import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// Vite config — proxy `/api` to the Rails backend in dev so we don't have
// to set up CORS/credentials for two different localhost ports.
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      "/api": {
        target: "http://localhost:3000",
        changeOrigin: true,
        secure: false
      }
    }
  }
});