CREATE VIEW mario_killers.BonoPorUsuario AS
SELECT a.grupo_familia AS grupo_familia, bf.codigo AS codigo_bono, p.id AS persona
FROM mario_killers.Bono_Farmacia bf
	JOIN mario_killers.Compra c ON c.id = bf.compra
	JOIN mario_killers.Persona p ON p.id = c.persona
	JOIN mario_killers.Afiliado a ON a.persona = p.id
GO

select * from mario_killers.BonoPorUsuario