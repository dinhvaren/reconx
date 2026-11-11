import packageJson from "../../package.json";

const currentYear = new Date().getFullYear();

export const APP_CONFIG = {
  name: "RECONX",
  version: packageJson.version,
  copyright: `© ${currentYear}, RECONX.`,
  meta: {
    title: "RECONX — Autonomous Penetration Testing Console",
    description: "Console for an LLM-driven autonomous penetration testing system",
  },
};
