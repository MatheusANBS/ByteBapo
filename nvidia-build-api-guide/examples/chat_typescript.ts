import OpenAI from "openai";

function requireEnv(name: string): string {
  const value = process.env[name];
  if (!value) throw new Error(`Defina a variável ${name}.`);
  return value;
}

const client = new OpenAI({
  apiKey: requireEnv("NVIDIA_API_KEY"),
  baseURL:
    process.env.NVIDIA_BASE_URL ??
    "https://integrate.api.nvidia.com/v1",
  timeout: 60_000,
  maxRetries: 0,
});

async function main(): Promise<void> {
  const response = await client.chat.completions.create({
    model: requireEnv("NVIDIA_MODEL"),
    messages: [
      {
        role: "system",
        content: "Responda tecnicamente em português.",
      },
      {
        role: "user",
        content: "Explique inversão de dependência em 5 linhas.",
      },
    ],
    temperature: 0.2,
    max_tokens: 600,
  });

  console.log(response.choices[0]?.message.content ?? "");
}

main().catch((error: unknown) => {
  console.error(error);
  process.exitCode = 1;
});
