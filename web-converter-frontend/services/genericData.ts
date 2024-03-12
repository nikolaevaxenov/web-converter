import { SQLQuery, SQLView } from "@/types/Query";

export const getAllTables = async () => {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_BACKEND_URL}/generic/`,
    {
      method: "GET",
    }
  );

  return response.json();
};

export const executeSQL = async (sqlQuery: SQLQuery) => {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_BACKEND_URL}/generic/`,
    {
      method: "POST",
      headers: {
        "Content-type": "application/json",
      },
      body: JSON.stringify(sqlQuery),
    }
  );

  if (!response.ok) {
    throw new Error(`${response.status} ${response.statusText}`);
  }

  return response.json();
};

export const createView = async (sqlView: SQLView) => {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_BACKEND_URL}/generic/view`,
    {
      method: "POST",
      headers: {
        "Content-type": "application/json",
      },
      body: JSON.stringify(sqlView),
    }
  );

  return response.json();
};
