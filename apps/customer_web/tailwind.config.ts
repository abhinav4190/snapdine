import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        paper: "#F7F5EF",
        ink: "#211E19",
        inkFaint: "#6B6558",
        rule: "#DAD5C7",
        moss: "#3F5B44",
        rosewood: "#9C5A46",
      },
      fontFamily: {
        jakarta: ["var(--font-jakarta)"],
      },
    },
  },
  plugins: [],
};
export default config;