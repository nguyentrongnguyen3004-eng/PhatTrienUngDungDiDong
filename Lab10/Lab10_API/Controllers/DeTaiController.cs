using Lab10_API.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Lab10_API.Controllers;

[Route("api/[controller]")]
[ApiController]
public class DeTaiController : ControllerBase
{
    private readonly QuanLyDeTaiContext _con;

    public DeTaiController(QuanLyDeTaiContext context)
    {
        _con = context;
    }

    // GET: api/DeTai?maLoai=DA&maCN=CNPM&search=...
    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] string? maLoai, [FromQuery] string? maCN, [FromQuery] string? search)
    {
        var query = _con.TblDeTais
            .Include(x => x.LoaiDeTai)
            .Include(x => x.ChuyenNganh)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(maLoai))
        {
            query = query.Where(x => x.MaLoai == maLoai);
        }

        if (!string.IsNullOrWhiteSpace(maCN))
        {
            query = query.Where(x => x.MaCN == maCN);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var kw = search.Trim().ToLower();
            query = query.Where(x =>
                x.MaDeTai.ToLower().Contains(kw) ||
                x.TenDeTai.ToLower().Contains(kw) ||
                x.TenGiangVien.ToLower().Contains(kw) ||
                x.NoiDung.ToLower().Contains(kw));
        }

        var result = await query
            .OrderBy(x => x.MaDeTai)
            .Select(x => new
            {
                x.MaDeTai,
                x.TenDeTai,
                x.TenGiangVien,
                x.NoiDung,
                x.YeuCau,
                x.SoLuongSV,
                x.HocKy,
                x.TrangThai,
                x.MaLoai,
                TenLoai = x.LoaiDeTai != null ? x.LoaiDeTai.TenLoai : x.MaLoai,
                x.MaCN,
                TenCN = x.ChuyenNganh != null ? x.ChuyenNganh.TenCN : x.MaCN
            })
            .ToListAsync();

        return Ok(result);
    }

    // GET: api/DeTai/{id}
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(string id)
    {
        var item = await _con.TblDeTais
            .Include(x => x.LoaiDeTai)
            .Include(x => x.ChuyenNganh)
            .Where(x => x.MaDeTai == id)
            .Select(x => new
            {
                x.MaDeTai,
                x.TenDeTai,
                x.TenGiangVien,
                x.NoiDung,
                x.YeuCau,
                x.SoLuongSV,
                x.HocKy,
                x.TrangThai,
                x.MaLoai,
                TenLoai = x.LoaiDeTai != null ? x.LoaiDeTai.TenLoai : x.MaLoai,
                x.MaCN,
                TenCN = x.ChuyenNganh != null ? x.ChuyenNganh.TenCN : x.MaCN
            })
            .FirstOrDefaultAsync();

        if (item == null)
        {
            return NotFound(new { message = $"Không tìm thấy đề tài có mã: {id}" });
        }

        return Ok(item);
    }

    // POST: api/DeTai
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] TblDeTai model)
    {
        try
        {
            if (await _con.TblDeTais.AnyAsync(x => x.MaDeTai == model.MaDeTai))
            {
                return BadRequest(new { message = $"Mã đề tài '{model.MaDeTai}' đã tồn tại!" });
            }

            _con.TblDeTais.Add(model);
            await _con.SaveChangesAsync();
            return Ok(model);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = "Không thể thêm đề tài mới.", error = ex.Message });
        }
    }

    // PUT: api/DeTai
    [HttpPut]
    public async Task<IActionResult> Update([FromBody] TblDeTai model)
    {
        try
        {
            var existing = await _con.TblDeTais.FirstOrDefaultAsync(x => x.MaDeTai == model.MaDeTai);
            if (existing == null)
            {
                return NotFound(new { message = $"Không tìm thấy đề tài có mã: {model.MaDeTai}" });
            }

            existing.TenDeTai = model.TenDeTai;
            existing.TenGiangVien = model.TenGiangVien;
            existing.NoiDung = model.NoiDung;
            existing.YeuCau = model.YeuCau;
            existing.SoLuongSV = model.SoLuongSV;
            existing.HocKy = model.HocKy;
            existing.TrangThai = model.TrangThai;
            existing.MaLoai = model.MaLoai;
            existing.MaCN = model.MaCN;

            _con.TblDeTais.Update(existing);
            await _con.SaveChangesAsync();
            return Ok(existing);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = "Cập nhật đề tài thất bại.", error = ex.Message });
        }
    }

    // DELETE: api/DeTai/{id}
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        try
        {
            var existing = await _con.TblDeTais.FirstOrDefaultAsync(x => x.MaDeTai == id);
            if (existing == null)
            {
                return NotFound(new { message = $"Không tìm thấy đề tài có mã: {id}" });
            }

            _con.TblDeTais.Remove(existing);
            await _con.SaveChangesAsync();
            return Ok(new { message = $"Đã xóa đề tài {id} thành công!" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = "Không thể xóa đề tài này.", error = ex.Message });
        }
    }
}
